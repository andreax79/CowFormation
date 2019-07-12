export DATALAKE="${PROJECT}-${ENV}-datalake"
export APPLICATIVE_LOGS="${PROJECT}-${ENV}-applicative-logs"

export LOGS_EXPIRATION_IN_DAYS=60

export S3_TAGS="
      - Key: Project
        Value: {{ PROJECT }}
      - Key: Owner
        Value: {{ OWNER }}
      - Key: Environment
        Value: {{ ENV }}
"
export S3_TAGS=$(echo "$S3_TAGS" | mo)

export PUBLIC_ACCESS_BLOCK_CONFIGURATION="
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true"

export BUCKET_ENCRYPTION="
        ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256"

