#!/usr/bin/env python3
"""Generate comparison plots for orchestration benchmark results.

Usage: python3 plot_results.py
Saves PNG files into the same directory.
"""
import math
import os
import matplotlib.pyplot as plt


DATA = {
    "platforms": ["Nomad", "Full K8s", "K3s", "Swarm"],
    "throughput_req_s": [6861.08, 4499.73, 4196.54, 4259.64],
    "avg_latency_ms": [7.22, 13.78, 14.40, 17.23],
    "p99_latency_ms": [315.04, 389.21, 370.62, 780.15],
    # Use Nomad clean-cluster scaling time from nomad_results (9.234s)
    "scaling_time_s": [9.234, 12.847, 13.573, 29.115],
    # Idle master memory (MB). K3s/Full K8s reported in Mi; keep units consistent (Mi ~ MB here)
    "idle_master_mem_mb": [358, 2048, 1666, 465],
    # Transfer rates observed during wrk (MB/s)
    "transfer_mb_s": [10.78, 7.06, 6.59, 6.69],
}


def ensure_outdir(path):
    os.makedirs(path, exist_ok=True)


def bar_labels(ax, rects, fmt="{:.1f}"):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(fmt.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=8)


def add_better_annotation(ax, better_is: str):
    """Add a small note indicating whether higher or lower values are better."""
    txt = f"Better: {better_is}"
    ax.text(0.99, 0.01, txt, transform=ax.transAxes, ha='right', va='bottom', fontsize=8,
            bbox=dict(facecolor='white', alpha=0.6, edgecolor='none'))


def plot_throughput(outdir):
    x = range(len(DATA["platforms"]))
    vals = DATA["throughput_req_s"]
    fig, ax = plt.subplots(figsize=(7, 4))
    bars = ax.bar(x, vals, color=['#4c72b0', '#55a868', '#c44e52', '#8172b2'])
    ax.set_xticks(x)
    ax.set_xticklabels(DATA["platforms"])
    ax.set_ylabel('Requests/sec')
    ax.set_title('Throughput')
    bar_labels(ax, bars, "{:.0f}")
    add_better_annotation(ax, 'higher is better')
    plt.tight_layout()
    path = os.path.join(outdir, 'throughput.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def plot_latency(outdir):
    x = range(len(DATA["platforms"]))
    vals = DATA["avg_latency_ms"]
    fig, ax = plt.subplots(figsize=(7, 4))
    bars = ax.bar(x, vals, color=['#c44e52', '#4c72b0', '#55a868', '#8172b2'])
    ax.set_xticks(x)
    ax.set_xticklabels(DATA["platforms"])
    ax.set_ylabel('Avg Latency (ms)')
    ax.set_title('Average Latency')
    bar_labels(ax, bars, "{:.2f}")
    add_better_annotation(ax, 'lower is better')
    plt.tight_layout()
    path = os.path.join(outdir, 'avg_latency.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def plot_p99(outdir):
    x = range(len(DATA["platforms"]))
    vals = DATA["p99_latency_ms"]
    fig, ax = plt.subplots(figsize=(7, 4))
    bars = ax.bar(x, vals, color=['#8172b2', '#c44e52', '#4c72b0', '#55a868'])
    ax.set_xticks(x)
    ax.set_xticklabels(DATA["platforms"])
    ax.set_ylabel('P99 / Max Latency (ms)')
    ax.set_title('Tail Latency (approx P99 / observed max)')
    bar_labels(ax, bars, "{:.0f}")
    add_better_annotation(ax, 'lower is better')
    plt.tight_layout()
    path = os.path.join(outdir, 'p99_latency.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def plot_scaling(outdir):
    x = range(len(DATA["platforms"]))
    vals = DATA["scaling_time_s"]
    fig, ax = plt.subplots(figsize=(7, 4))
    bars = ax.bar(x, vals, color=['#55a868', '#4c72b0', '#c44e52', '#8172b2'])
    ax.set_xticks(x)
    ax.set_xticklabels(DATA["platforms"])
    ax.set_ylabel('Scaling Time (s)')
    ax.set_title('Time to Scale to 50 Replicas')
    bar_labels(ax, bars, "{:.2f}")
    add_better_annotation(ax, 'lower is better')
    plt.tight_layout()
    path = os.path.join(outdir, 'scaling_time.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def plot_idle_memory(outdir):
    x = range(len(DATA["platforms"]))
    vals = DATA["idle_master_mem_mb"]
    fig, ax = plt.subplots(figsize=(7, 4))
    bars = ax.bar(x, vals, color=['#8172b2', '#c44e52', '#4c72b0', '#55a868'])
    ax.set_xticks(x)
    ax.set_xticklabels(DATA["platforms"])
    ax.set_ylabel('Idle Master Memory (MB)')
    ax.set_title('Idle Master Memory Footprint')
    bar_labels(ax, bars, "{:.0f}")
    add_better_annotation(ax, 'lower is better')
    plt.tight_layout()
    path = os.path.join(outdir, 'idle_master_memory.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def plot_summary(outdir):
    # Multi-panel summary
    fig, axs = plt.subplots(2, 2, figsize=(12, 8))
    idx = range(len(DATA["platforms"]))
    axs[0, 0].bar(idx, DATA['throughput_req_s'], color='#4c72b0')
    axs[0, 0].set_title('Throughput (req/s)')
    axs[0, 1].bar(idx, DATA['avg_latency_ms'], color='#c44e52')
    axs[0, 1].set_title('Avg Latency (ms)')
    axs[1, 0].bar(idx, DATA['p99_latency_ms'], color='#8172b2')
    axs[1, 0].set_title('P99 Latency (ms)')
    axs[1, 1].bar(idx, DATA['scaling_time_s'], color='#55a868')
    axs[1, 1].set_title('Scaling Time (s)')
    for ax in axs.flatten():
        ax.set_xticks(idx)
        ax.set_xticklabels(DATA['platforms'], rotation=30)
    plt.tight_layout()
    path = os.path.join(outdir, 'summary.png')
    fig.savefig(path)
    plt.close(fig)
    print('Saved', path)


def save_formats(fig, outpath_base, dpi=300):
    png = outpath_base + '.png'
    fig.savefig(png, dpi=dpi)
    print('Saved', png)


def plot_line_metric(name, values, ylabel, outdir, logscale=False):
    x = list(range(len(DATA['platforms'])))
    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.plot(x, values, marker='o', linewidth=2)
    for i, v in enumerate(values):
        ax.annotate(f"{v:.2f}", (x[i], values[i]), textcoords="offset points", xytext=(0,6), ha='center', fontsize=9)
    ax.set_xticks(x)
    ax.set_xticklabels(DATA['platforms'])
    ax.set_ylabel(ylabel)
    ax.set_title(name)
    ax.grid(True, linestyle='--', alpha=0.4)
    if logscale:
        ax.set_yscale('log')
    plt.tight_layout()
    base = os.path.join(outdir, name.lower().replace(' ', '_'))
    save_formats(fig, base)
    plt.close(fig)


def plot_additional_line_plots(outdir):
    # Throughput line
    plot_line_metric('Throughput_req_s', DATA['throughput_req_s'], 'Requests/sec', outdir)
    add_better_annotation(plt.gca(), 'higher is better')
    # Transfer per second
    plot_line_metric('Transfer_MB_s', DATA['transfer_mb_s'], 'MB/s', outdir)
    add_better_annotation(plt.gca(), 'higher is better')
    # Throughput normalized by idle master memory (req/s per MB)
    norm = [t / m if m else 0 for t, m in zip(DATA['throughput_req_s'], DATA['idle_master_mem_mb'])]
    plot_line_metric('Throughput_per_MB_master', norm, 'req/s per MB', outdir)
    add_better_annotation(plt.gca(), 'higher is better')
    # Latency line (log scale to show differences)
    plot_line_metric('Avg_latency_ms', DATA['avg_latency_ms'], 'ms', outdir, logscale=False)
    add_better_annotation(plt.gca(), 'lower is better')
    plot_line_metric('P99_latency_ms', DATA['p99_latency_ms'], 'ms', outdir, logscale=True)
    add_better_annotation(plt.gca(), 'lower is better')


def main():
    outdir = os.path.dirname(__file__)
    ensure_outdir(outdir)
    plot_throughput(outdir)
    plot_latency(outdir)
    plot_p99(outdir)
    plot_scaling(outdir)
    plot_idle_memory(outdir)
    plot_summary(outdir)
    # Additional detailed line plots and vector exports
    plot_additional_line_plots(outdir)


if __name__ == '__main__':
    main()
