# CowFormation
Mustache templates for AWS CloudFormation, in pure bash.

Example
-------

    ApplicativeLogS3Bucket:
      Type: AWS::S3::Bucket
      Properties:
        BucketName: {{ APPLICATIVE_LOGS }}
        BucketEncryption: {{ BUCKET_ENCRYPTION }}
        PublicAccessBlockConfiguration: {{ PUBLIC_ACCESS_BLOCK_CONFIGURATION }}
        LifecycleConfiguration:
          Rules:
          - Id: DeleteOldFiles
            ExpirationInDays: {{ LOGS_EXPIRATION_IN_DAYS }}
            Status: Enabled
        Tags: {{ S3_TAGS }}


Requirements
------------

* Bash 3.x
* AWS Command Line Interface

Usage
-----

1) Edit `vars/0_commons.sh`
The following variables are require:

    export STACK_NAME="test"        # CloudFormation stack name
    export FORMAT="yaml"            # CloudFormation template format (yaml or json)
    export AWS_REGION="eu-west-1"   # AWS Region
    export AWS_PROFILE="stage"      # AWS Profile

2) Add other .sh files exporting eviron variables in `vars` folder. You must make sure your data is in the environment when the template is rendered. The files are imported in lexicographical order.

3) Edit/add templates parts (json/yaml) in `parts` folder. The files are concatenated in lexicographical order.

4) Run `./cow.sh` for creating/updating the CloudFormation stack.

   ./cow.sh

Links
-----

* Mustache Templates in Bash - https://github.com/tests-always-included/mo
* Mustache, Logic-less templates- https://mustache.github.io/
* ShellCheck a static analysis tool for shell scripts - https://github.com/koalaman/shellcheck
* AWS Command Line Interface-  https://aws.amazon.com/cli/
