#!/bin/bash

MAX_PARALLEL_JOBS=4
CURRENT_JOBS=0

run_and_control_parallelism() {
    "$@" &
    ((CURRENT_JOBS++))
    if [[ $CURRENT_JOBS -ge $MAX_PARALLEL_JOBS ]]; then
        wait
        CURRENT_JOBS=0
    fi
}

for beta in 0.01 0.1 0.5
do
    for alg in fedcg fedavg scaffold fednova
    do
        run_and_control_parallelism python experiments.py --model=simple-cnn \
            --dataset=femnist \
            --alg=$alg \
            --lr=0.01 \
            --batch-size=64 \
            --epochs=10 \
            --n_parties=10 \
            --rho=0.9 \
            --comm_round=50 \
            --partition=noniid-labeldir \
            --beta=$beta \
            --device='cpu' \
            --datadir='./data/' \
            --logdir='./logs/' \
            --noise=0 \
            --init_seed=1
    done
done

# Wait for any remaining background jobs
wait
