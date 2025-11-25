# Kubernetes configuration

# Aliases
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias ka="kubectl apply"
alias kdel="kubectl delete"
alias kex="kubectl exec"
alias kl="kubectl logs"
alias kpf="kubectl port-forward"
alias kc="kubectl create"
alias ke="kubectl edit"
alias kr="kubectl run"
alias kt="kubectl top"
alias kctx="kubectx"
alias kns="kubens"

# Functions
kexec() {
  kubectl exec -it "$1" -- /bin/bash
}

kexec-sh() {
  kubectl exec -it "$1" -- /bin/sh
}

klogs() {
  kubectl logs -f "$1"
}

kdesc() {
  kubectl describe "$1" "$2"
}

kget() {
  kubectl get "$1" "$2"
}

kdelete() {
  kubectl delete "$1" "$2"
}

kapply() {
  kubectl apply -f "$1"
}

kctx-switch() {
  kubectx "$1"
}

kns-switch() {
  kubens "$1"
}

