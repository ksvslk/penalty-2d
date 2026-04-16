with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# I will use replace_file_content instead because it's much safer than regexing a huge block.
