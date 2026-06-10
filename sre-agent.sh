#!/bin/bash
# SRE AI Operations Automation Agent for EKS

echo "===================================================="
echo "🤖 STARTING AI-ASSISTED KUBERNETES OPERATIONS SCAN"
echo "===================================================="

# 1. Run core cluster analysis using the AI backend
echo "▶ Running cluster triage analysis..."
k8sgpt analyze --explain --filter Pod,Service,Gateway,Deployment

# 2. Check for recent container log anomalies
echo ""
echo "===================================================="
echo "📋 EXTRACELLULAR LOG ANOMALY INSPECTION"
echo "===================================================="

FAILED_PODS=$(kubectl get pods --no-headers | grep -v "Running" | awk '{print $1}')

if [ -z "$FAILED_PODS" ]; then
    echo "✔ All pods running normally. Checking app log signatures..."
    # Inspect sample production application logs for runtime errors
    kubectl logs deployment/fitness-app-deployment --tail=20 | grep -iE "error|exception|fail" || echo "✔ No critical exceptions found in application logs."
else
    for POD in $FAILED_PODS; do
        echo "❌ Anomaly detected in Pod: $POD"
        echo "--- Latest Lifecycle Events ---"
        kubectl describe pod $POD | tail -n 15
        echo "--- Recent Pod Logs ---"
        kubectl logs $POD --tail=20
    done
fi

echo "===================================================="
echo "🤖 SCAN COMPLETE - END OF SRE REPORT"
echo "===================================================="