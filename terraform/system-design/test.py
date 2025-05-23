import boto3
import json
from botocore.exceptions import ClientError

BUCKET_NAME = "test-bucket-112469fa-2f67-a1b5-39cd-1634918e2d52"


def get_s3_client_with_assumed_role(
    customer_username: str, region: str = "us-east-1"
) -> boto3.client:
    sts = boto3.client("sts", region_name=region)
    role_name = "external_user_file_storage_role"
    session_policy = {
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["s3:*"],
                "Resource": [
                    f"arn:aws:s3:::{BUCKET_NAME}/{customer_username}/*",
                ],
            },
            {
                "Effect": "Allow",
                "Action": ["s3:ListBucket"],
                "Resource": [f"arn:aws:s3:::{BUCKET_NAME}"],
                "Condition": {"StringLike": {"s3:prefix": [f"{customer_username}/*"]}},
            },
        ]
    }

    assume_role_kwargs = {
        "RoleArn": f"arn:aws:iam::193672753492:role/{role_name}",
        "RoleSessionName": f"{role_name}-{customer_username}",
        "Policy": json.dumps(session_policy),
        "DurationSeconds": 900,  # min 15 min, max 1 hour
    }

    response = sts.assume_role(**assume_role_kwargs)
    creds = response["Credentials"]
    return boto3.client(
        "s3",
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
        region_name=region,
    )


def external_bucket_access(customer_username: str) -> None:
    file_name = "d1.txt"
    s3_client = get_s3_client_with_assumed_role(customer_username)
    try:
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=f"{customer_username}/{file_name}",
            # Key=f"cust3/{file_name}",
            Body="Hello, world!",
        )
    except ClientError as e:
        print(f"Unexpected error: {e}")

    try:
        response = s3_client.list_objects_v2(
            Bucket=BUCKET_NAME, Prefix=f"{customer_username}/"
        )
        # response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=f"cust2/")
        print([c["Key"] for c in response["Contents"]])
    except ClientError as e:
        print(f"Unexpected error: {e}")


external_bucket_access("cust1")
