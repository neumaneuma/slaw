# slaw
- centralized root user?
- best pattern for `assume_role` meta-argument? an empty account that does nothing, but is used for authn, then assuming different roles via `assume_role`?
- should state file be kept in management account or dedicated member account?
- should different aws accounts be managed with different tf root modules? or everything under same root module, and just use provider meta-arguments like in slaw-terraform?
