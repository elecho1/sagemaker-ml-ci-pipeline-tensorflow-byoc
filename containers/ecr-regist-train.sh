# ACCOUNT_ID=`aws sts get-caller-identity --query 'Account' --output text`
# ACCOUNT_ID='420964472730' 
# REGION='us-east-1'
REGION=${AWS_DEFAULT_REGION}
REGISTRY_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com" 
# ECR_REPOGITORY='sagemaker-tf-nightly-gpu'
IMAGE_TAG=$(git rev-parse --short HEAD)

echo "========"
echo ${IMAGE_TAG}

# train
ECR_REPOGITORY="${ECR_REPOGITORY_PREFIX}-train"
IMAGE_URI="${REGISTRY_URL}/${ECR_REPOGITORY}"

echo "repo name prefix=-=-===--="
echo ${ECR_REPOGITORY_PREFIX}

aws ecr get-login-password | docker login --username AWS --password-stdin $REGISTRY_URL
aws ecr create-repository --repository-name $ECR_REPOGITORY

docker build -t $ECR_REPOGITORY containers/train/
docker tag "${ECR_REPOGITORY}${IMAGE_TAG}" $IMAGE_URI
docker push $IMAGE_URI

echo "Container registered. URI:${IMAGE_URI}"

# evaluate
ECR_REPOGITORY="${ECR_REPOGITORY_PREFIX}-evaluate"
IMAGE_URI="${REGISTRY_URL}/${ECR_REPOGITORY}"

aws ecr get-login-password | docker login --username AWS --password-stdin $REGISTRY_URL
aws ecr create-repository --repository-name $ECR_REPOGITORY

docker build -t $ECR_REPOGITORY containers/evaluate/
docker tag "${ECR_REPOGITORY}${IMAGE_TAG}" $IMAGE_URI
docker push $IMAGE_URI

echo "Container registered. URI:${IMAGE_URI}"
