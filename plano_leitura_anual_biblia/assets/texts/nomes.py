import os
import json

# Caminho da pasta onde está o script
pasta = os.path.dirname(os.path.abspath(__file__))

for nome_arquivo in os.listdir(pasta):
    if nome_arquivo.endswith(".json"):
        caminho_arquivo = os.path.join(pasta, nome_arquivo)

        try:
            with open(caminho_arquivo, 'r', encoding='utf-8') as f:
                conteudo = json.load(f)

            # Verifica se o conteúdo é um dicionário (como no exemplo)
            if isinstance(conteudo, dict):
                conteudo["Santo Agostinho"] = " "
                conteudo["Santo Tomás de Aquino"] = " "

                with open(caminho_arquivo, 'w', encoding='utf-8') as f:
                    json.dump(conteudo, f, ensure_ascii=False, indent=2)

                print(f'Adicionados comentários vazios em {nome_arquivo}')
            else:
                print(f"Formato inesperado em {nome_arquivo}, ignorado.")

        except Exception as e:
            print(f"Erro ao processar {nome_arquivo}: {e}")