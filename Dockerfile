FROM public.ecr.aws/lambda/provided:al2

RUN yum update &&yum install git jq -y

# Copy custom runtime bootstrap
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
# Copy function code
COPY function.sh ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "function.handler" ]