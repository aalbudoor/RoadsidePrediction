#!/bin/bash
#SBATCH --job-name=seal-ablation
#SBATCH --array=0-4
#SBATCH --partition=ws-ia
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=23:59:00
#SBATCH --output=results/logs/ablation_%A_%a.out
#SBATCH --error=results/logs/ablation_%A_%a.err

# ---------- Environment ----------
# Python 3.10 and SUMO 1.12.0 available system-wide; no modules needed

# Activate venv (create once: python3 -m venv ~/venvs/seal && pip install -r requirements.txt)
source ~/venvs/seal/bin/activate

cd ~/RoadsidePrediction/BackEnd

mkdir -p results/logs

# ---------- Experiment definitions ----------
# Each array index maps to one experiment
case $SLURM_ARRAY_TASK_ID in
    0)
        TOPO="grid-5x5"
        DEMAND="150"
        ;;
    1)
        TOPO="grid-5x5"
        DEMAND="360"
        ;;
    2)
        TOPO="grid-5x5"
        DEMAND="600"
        ;;
    3)
        TOPO="grid-3x3"
        DEMAND="150 360 600"
        ;;
    4)
        TOPO="cologne-8"
        DEMAND="150 360 600"
        ;;
esac

echo "=== Job $SLURM_ARRAY_TASK_ID | Topology: $TOPO | Demand: $DEMAND ==="
echo "Started: $(date)"

python scripts/run_extension_ablation.py \
    --ablation strategy \
    --topologies $TOPO \
    --demand-levels $DEMAND \
    --training-seeds 42 \
    --n-episodes 30 \
    --n-eval-runs 5

echo "Finished: $(date)"
