from flytekit import task, workflow


@task(container_image="europe-west1-docker.pkg.dev/nav-data-images-prod/ghcr/flyteorg/flytekit:py3.12-1.16.14")
def add(a: int, b: int) -> int:
    return a + b


@task(container_image="europe-west1-docker.pkg.dev/nav-data-images-prod/ghcr/flyteorg/flytekit:py3.12-1.16.14")
def multiply(a: int, b: int) -> int:
    return a * b


@workflow
def math_workflow(x: int = 3, y: int = 4) -> int:
    """Simple math workflow: computes (x + y) * y."""
    s = add(a=x, b=y)
    return multiply(a=s, b=y)
