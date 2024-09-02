import os

def merge_files(input_folder, output_file):
    # 定义文件的优先顺序
    priority_files = [
        'header.pnml',
        'template.pnml',
        'railtypetable.pnml',
        'vehicleid.pnml', 
        'functions.pnml',    
        'wagons.pnml',
        'id.pnml',
    ]

    # 收集所有 .pnml 文件
    all_files = []
    for root, dirs, files in os.walk(input_folder):
        for filename in files:
            if filename.endswith('.pnml'):
                all_files.append(os.path.join(root, filename))
    
    # 按照优先顺序和字母顺序排序文件
    def file_sort_key(filename):
        basename = os.path.basename(filename)
        if basename in priority_files:
            return (priority_files.index(basename), basename)
        else:
            return (len(priority_files), basename)
    
    sorted_files = sorted(all_files, key=file_sort_key)

    # 合并文件内容
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for file_path in sorted_files:
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                outfile.write(content)
                outfile.write('\n')  # 可选: 添加换行符以分隔文件内容
    
    if sorted_files:
        print(f"所有 .pnml 文件已合并到 {output_file}")
    else:
        print(f"未找到 .pnml 文件。生成了一个空的 '{output_file}' 文件。")

# 获取当前脚本所在目录
script_directory = os.path.dirname(os.path.abspath(__file__))
output_file = os.path.join(script_directory, 'china_set_metro.nml')

# 调用函数
merge_files(script_directory, output_file)
