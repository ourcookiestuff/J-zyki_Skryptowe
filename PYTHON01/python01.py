# Jakub Dziurka

import sys
import time
import string
import random
import threading
import multiprocessing as mp

NUM_RECORDS = 100_000
WORKERS = 6
SCORE_LETTERS = "parallelism"


def generate_data(n):
    data = []
    for i in range(n):
        text = ' '.join(''.join(random.choices(string.ascii_lowercase, k=random.randint(3, 10))) for _ in range(random.randint(2, 100)))
        data.append({"id": i, "text": text})
    return data


def process_record(record):
    text = record["text"]
    words = text.split()
    word_count = len(words)
    unique_letters = len(set(text.replace(" ", "")))
    score = sum(text.count(c) for c in SCORE_LETTERS)

    return {
        "word_count": word_count,
        "unique_letters": unique_letters,
        "score": score,
    }


# część sekwencyjna

def run_sequential(data):
    results = {}
    for rec in data:
        results[rec["id"]] = process_record(rec)
    return results


# część procesowa

def process_chunk(chunk):
    local_results = {}
    for rec in chunk:
        local_results[rec["id"]] = process_record(rec)
    return local_results


def run_multiprocessing(data):
    chunks = [data[i::WORKERS] for i in range(WORKERS)]
    with mp.Pool(WORKERS) as pool:
        results = pool.map(process_chunk, chunks)
    
    merged = {}
    for part in results:
        merged.update(part)
    return merged


# część wątkowa

def threading_worker(data_slice, results, lock=None):
    for rec in data_slice:
        res = process_record(rec)
        if lock:
            with lock:
                results[rec["id"]] = res
        else:
            results[rec["id"]] = res


def run_threading(data, use_lock):
    results = {}
    lock = threading.Lock() if use_lock else None
    threads = []

    slices = [data[i::WORKERS] for i in range(WORKERS)]
    for sl in slices:
        t = threading.Thread(target=threading_worker, args=(sl, results, lock))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()

    return results


if __name__ == "__main__":
    print(f"GIL = {sys._is_gil_enabled()}")

    data = generate_data(NUM_RECORDS)

    ### Sekwencyjnie
    start = time.perf_counter()
    results_seq = run_sequential(data)
    end = time.perf_counter()

    time_seq = end - start
    print(f"Sequential time: {time_seq:.3f} s")

    ### Multiprocessing
    start = time.perf_counter()
    results_mp = run_multiprocessing(data)
    end = time.perf_counter()

    time_mp = end - start
    print(f"Multiprocessing time: {time_mp:.3f} s | Czy poprawny?: {results_seq == results_mp}")

    ### Threading
    start = time.perf_counter()
    results_th_no_lock = run_threading(data, use_lock=False)
    end = time.perf_counter()

    time_th_no_lock = end - start
    print(f"Threading (no lock) time: {time_th_no_lock:.3f} s | Czy poprawny?: {results_seq == results_th_no_lock}")

    ### Threading z synchronizacja
    start = time.perf_counter()
    results_th_lock = run_threading(data, use_lock=True)
    end = time.perf_counter()

    time_th_lock = end - start
    print(f"Threading (with lock) time: {time_th_lock:.3f} s | Czy poprawny?: {results_seq == results_th_lock}")

