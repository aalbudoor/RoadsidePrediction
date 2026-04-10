#!/bin/bash
#SBATCH --job-name=seal-ablation
#SBATCH --array=0-89
#SBATCH --partition=ws-ia
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=23:59:00
#SBATCH --output=results/logs/ablation_%A_%a.out
#SBATCH --error=results/logs/ablation_%A_%a.err

# ---------- Environment ----------
# Python 3.10 and SUMO 1.12.0 available system-wide; no modules needed
source ~/venvs/seal/bin/activate

cd ~/RoadsidePrediction/BackEnd
mkdir -p results/logs

# ---------- Experiment grid ----------
# 9 (topology, demand) combos × 10 strategies = 90 tasks
# index = combo_idx * 10 + strategy_idx
TOPOS=(grid-3x3 grid-3x3 grid-3x3 grid-5x5 grid-5x5 grid-5x5 cologne-8 cologne-8 cologne-8)
DEMS=(150 360 600 150 360 600 150 360 600)
STRATS=(marl mean_field ctde gossip hierfed feddistill fedrl sarl fixed_time max_pressure)

COMBO=$(( SLURM_ARRAY_TASK_ID / 10 ))
STRAT=$(( SLURM_ARRAY_TASK_ID % 10 ))

TOPO=${TOPOS[$COMBO]}
DEMAND=${DEMS[$COMBO]}
STRATEGY=${STRATS[$STRAT]}

echo "=== Task $SLURM_ARRAY_TASK_ID | Topology: $TOPO | Demand: $DEMAND | Strategy: $STRATEGY ==="
echo "Started: $(date)"

python scripts/run_extension_ablation.py \
    --ablation strategy \
    --topologies $TOPO \
    --demand-levels $DEMAND \
    --training-seeds 42 \
    --n-episodes 30 \
    --n-eval-runs 5 \
    --strategies $STRATEGY \
    --campaign-suffix "${TOPO}_d${DEMAND}_${STRATEGY}"

echo "Finished: $(date)"
