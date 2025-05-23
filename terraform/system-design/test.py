import boto3


def get_s3_client_with_assumed_role(
    session_name: str, customer_username: str, region: str = "us-east-1"
) -> boto3.client:
    sts = boto3.client("sts", region_name=region)
    assume_role_kwargs = {
        "RoleArn": "arn:aws:iam::193672753492:role/external_user_file_storage_role",
        "RoleSessionName": session_name,
    }
    # assume_role_kwargs["Policy"] = json.dumps({})
    response = sts.assume_role(**assume_role_kwargs)
    creds = response["Credentials"]
    return boto3.client(
        "s3",
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
        region_name=region,
    )


# Example usage:
session_name = "test-session"
session_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": "arn:aws:s3:::test-bucket-<uuid>",
        }
    ],
}


def external_bucket_access(customer_username: str) -> None:
    s3_client = get_s3_client_with_assumed_role(session_name, customer_username)
    bucket_name = "test-bucket-112469fa-2f67-a1b5-39cd-1634918e2d52"
    # s3_client.put_object(
    #     Bucket=bucket_name,
    #     Key="cust3/b3.txt",
    #     Body="Hello, world!"
    # )
    response = s3_client.list_objects_v2(Bucket=bucket_name)
    print([c["Key"] for c in response["Contents"]])


external_bucket_access("cust1")
