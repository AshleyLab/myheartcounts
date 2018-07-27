sbatch -J "aws_parse" -o logs_aws/aws.o -e logs_aws/aws.e -p euan --time=24:00:00 aws_parser.sh

