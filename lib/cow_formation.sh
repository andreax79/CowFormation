#!/usr/bin/env bash

parse_args() {
    TEST=0
    ASSUME_YES=0
    while getopts "ty" arg; do
        case $arg in
        t) # Test - only generate the template file
            TEST=1
            ;;
        y) # Automatic yes to prompt
            ASSUME_YES=1
            ;;
        *) # Illegal option
            exit 2
        esac
    done
}

import_vars() {
    # Import the files in 'vars'
    for filename in vars/*.sh; do
        source "${filename}"
    done
}

generate_template() {
    # Generate the template
    TEMPLATE="${STACK_NAME}.${FORMAT}"
    cat parts/*.${FORMAT} | mo -u > $TEMPLATE
    if [ "$TEST" == 1 ]; then
        exit 0
    fi
}

describe_stacks() {
    # Check if the cloudformation stack exist
    aws cloudformation describe-stacks \
        --profile ${AWS_PROFILE} \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION} \
        --no-paginate > /dev/null
}

create_change_set() {
    # Create a change set
    TS=$(/bin/date "+%Y-%m-%d-%H-%M-%S")
    CHANGE_SET_NAME="Update-${TS}"
    aws cloudformation create-change-set \
        --profile ${AWS_PROFILE} \
        --stack-name ${STACK_NAME} \
        --template-body file://${TEMPLATE} \
        --region ${AWS_REGION} \
        --capabilities CAPABILITY_NAMED_IAM \
        --change-set-name "${CHANGE_SET_NAME}"
}

change_set_create_complete() {
    # Wait until the change set is created
    aws cloudformation wait change-set-create-complete \
        --profile ${AWS_PROFILE} \
        --change-set-name "${CHANGE_SET_NAME}" \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION}
}

describe_change_set() {
    # Describe the change set
    aws cloudformation describe-change-set \
        --profile ${AWS_PROFILE} \
        --change-set-name "${CHANGE_SET_NAME}" \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION}
}

execute_change_set() {
    # Execute the change set
    aws cloudformation execute-change-set \
        --profile ${AWS_PROFILE} \
        --change-set-name "${CHANGE_SET_NAME}" \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION}
}

delete_change_set() {
    # Delte the change set
    aws cloudformation delete-change-set \
        --profile ${AWS_PROFILE} \
        --change-set-name "${CHANGE_SET_NAME}" \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION}
}

create_stack() {
    # Create a new cloudformation stack
    aws cloudformation create-stack \
        --profile ${AWS_PROFILE} \
        --stack-name ${STACK_NAME} \
        --template-body file://${TEMPLATE} \
        --region ${AWS_REGION} \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection \
        --output text && \
    aws cloudformation wait stack-create-complete \
        --profile ${AWS_PROFILE} \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION}
}

ask_confirm() {
    # Ask for apply changes confirmation
    if [ $ASSUME_YES == 1 ]; then
        return 0
    else
        echo "Do you want to apply the changes? [y/N] "
        read -r answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            return 0
        else
            return 1
        fi
    fi
}

cow_formation() {
    # Main
    parse_args "$@"
    import_vars
    generate_template
    if describe_stacks; then
        echo "Stack ${STACK_NAME} exists, update it."
        if create_change_set && change_set_create_complete && describe_change_set; then
            if ask_confirm; then
                execute_change_set
            else
                delete_change_set
            fi
        else
            exit 1
        fi
    else
        echo "Stack does not exists, create it."
        create_stack
    fi
}

