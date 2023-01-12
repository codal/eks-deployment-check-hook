# EKS Deployment Check hook

Access your EKS cluster via `kubectl` in a Github Action. No fuss, no messing around with special
kubeconfigs, just ensure you have `eks:ListCluster` and `eks:DescribeCluster` rights on your
user.

## Example configuration

### Supplying AWS credentials
You can supply your AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, the region your cluster is in, and the cluster name, application namespace and application name as app_name.

```yaml
jobs:
  jobName:
    name: Update deploy
    runs-on: ubuntu-latest 
    steps:
      # --- #
      - name: Build and push CONTAINER_NAME
        uses: yashpandya-codal/eks-deployment-check-hook@main
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: ${{ secrets.AWS_REGION }}
          cluster_name: ${{ secrets.CLUSTER_NAME }}
          namespace: ${{ secrets.NAMESPACE }}
          app_name: ${{ secrets.APP_NAME }}
      # --- #
```

### Using the AWS credentials present on the environment
If credentials are already present on the environment you don't need to supply them.

```yaml
jobs:
  jobName:
    name: Update deploy
    runs-on: ubuntu-latest 
    env:
      aws_region: eu-central-1
    steps:
      - name: AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.MY_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.MY_AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.aws_region }}
      # --- #
      - name: Build and push deployment-check
        uses: yashpandya-codal/eks-deployment-check-hook@main
        with:
          cluster_name: ${{ secrets.CLUSTER_NAME }}
          namespace: ${{ secrets.NAMESPACE }}
          app_name: ${{ secrets.APP_NAME }}
      # --- #
```

### Outputs

The action exports the following outputs:
- `deployment-check-out`: The output of `deployment-check function hook`.

```yaml
jobs:
  jobName:
    name: Update deploy
    runs-on: ubuntu-latest 
    steps:
      # --- #
      - name: Build and push deployment-check
        id: deploycheckhook
        uses: yashpandya-codal/eks-deployment-check-hook@main
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: ${{ secrets.AWS_REGION }}
          cluster_name: ${{ secrets.CLUSTER_NAME }}
          namespace: ${{ secrets.NAMESPACE }}
          app_name: ${{ secrets.APP_NAME }}
      # --- #
      - name: Use the output
        run: echo "${{ steps.deploycheckhook.outputs.deployment-check-out }}"
```


### Github action hook is inspired from @ianbelcher/eks-kubectl-action, Thank you!