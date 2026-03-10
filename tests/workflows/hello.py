from flytekit import task, workflow


@task(container_image="europe-west1-docker.pkg.dev/nav-data-images-prod/ghcr/flyteorg/flytekit:py3.12-1.16.14")
def say_hello() -> str:
    return "hello from dataplattform-ci"


@workflow
def my_workflow() -> str:
    return say_hello()
