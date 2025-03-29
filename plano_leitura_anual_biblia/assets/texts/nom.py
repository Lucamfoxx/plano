import os
import json

def process_json_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.json'):
            file_path = os.path.join(directory, filename)
            with open(file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)
            
            # Função recursiva para substituir ocorrências de '\n\n\n\n\n\n' por '\n\n' nos valores das chaves
            def replace_newlines(obj):
                if isinstance(obj, dict):
                    for key, value in obj.items():
                        obj[key] = replace_newlines(value)
                elif isinstance(obj, list):
                    obj = [replace_newlines(item) for item in obj]
                elif isinstance(obj, str):
                    obj = obj.replace('\n\n\n\n\n\n', '\n\n')
                return obj

            # Aplica a função de substituição no objeto JSON
            data = replace_newlines(data)
            
            # Grava os dados de volta no arquivo
            with open(file_path, 'w', encoding='utf-8') as file:
                json.dump(data, file, ensure_ascii=False, indent=4)
            print(f"Processed file: {filename}")

# Define o diretório onde estão os arquivos JSON
directory = '/Users/magao-/Documents/Projetos/leia_a_biblia_ano/assets/texts/'

# Chama a função para processar os arquivos JSON
process_json_files(directory)