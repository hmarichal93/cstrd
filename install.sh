#!/bin/bash

# Define the file path for utils.py
REPO_PATH=$(pwd)
UTILS_FILE_PATH="${REPO_PATH}/cross_section_tree_ring_detection/utils.py"
IO_FILE_PATH="${REPO_PATH}/cross_section_tree_ring_detection/io.py"

# Nuevo contenido para la función save_config
read -r -d '' NEW_FUNCTION_UTILS << EOF
def save_config(args, output_dir, repo_path="${REPO_PATH}"):

    config = load_config()
    config['result_path'] = str(output_dir)

    if args.nr:
        config['nr'] = args.nr
    if args.hsize and args.wsize:
        if args.hsize > 0 and args.wsize > 0:
            config['resize'] = [args.hsize, args.wsize]
    if args.min_chain_length:
        config["min_chain_length"] = args.min_chain_length
    if args.alpha:
        config["alpha"] = args.alpha
    if args.sigma:
        config['sigma'] = args.sigma
    if args.th_high:
        config['th_high'] = args.th_high
    if args.th_low:
        config['th_low'] = args.th_low
    if args.debug:
        config['debug'] = True

    config['devernay_path'] = str(Path(repo_path) / "externas/devernay_1.0")
    write_json(config, Path(repo_path) / 'config/general.json')
    return 0
EOF

# Reemplazar la función save_config completa en utils.py
awk -v new_func="$NEW_FUNCTION_UTILS" '
/^def save_config\(/ { in_func=1; print new_func; next }
/^def / && in_func { in_func=0 }
!in_func
' "$UTILS_FILE_PATH" > "${UTILS_FILE_PATH}.tmp" && mv "${UTILS_FILE_PATH}.tmp" "$UTILS_FILE_PATH"

echo "Replaced save_config function in $UTILS_FILE_PATH"

# Nuevo contenido para la función load_config
read -r -d '' NEW_FUNCTION_IO << EOF
def load_config(default=True) -> dict:
    config_path = os.path.join("${REPO_PATH}/config", "default.json" if default else "general.json")
    return load_json(config_path)
EOF

# Reemplazar la función load_config completa en io.py
awk -v new_func="$NEW_FUNCTION_IO" '
/^def load_config\(/ { in_func=1; print new_func; next }
/^def / && in_func { in_func=0 }
!in_func
' "$IO_FILE_PATH" > "${IO_FILE_PATH}.tmp" && mv "${IO_FILE_PATH}.tmp" "$IO_FILE_PATH"

echo "Replaced load_config function in $IO_FILE_PATH"
