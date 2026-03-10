from flytekit import task, workflow


@task
def say_hello() -> str:
    return "hello from dataplattform-ci"


@workflow
def my_workflow() -> str:
    return say_hello()
