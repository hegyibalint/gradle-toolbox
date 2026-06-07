function __gt_util_human_kb --description 'Format a size given in KiB as a human-readable string (e.g. 4.2G)'
    awk -v kb=$argv[1] 'BEGIN {
        units = "KMGT"
        i = 1
        v = kb
        while (v >= 1024 && i < 4) { v /= 1024; i++ }
        fmt = (v >= 10 || v == int(v)) ? "%.0f%s\n" : "%.1f%s\n"
        printf fmt, v, substr(units, i, 1)
    }'
end
