import os
import json

# Caminho da pasta onde o script está localizado
pasta = os.path.dirname(os.path.abspath(__file__))

# Percorre todos os arquivos da pasta
for nome_arquivo in os.listdir(pasta):
    if nome_arquivo.endswith(".json"):
        caminho_arquivo = os.path.join(pasta, nome_arquivo)

        try:
            with open(caminho_arquivo, 'r', encoding='utf-8') as f:
                conteudo = json.load(f)

            # Remove a chave "Extras", se existir
            alterado = False
            for grupo in conteudo:
                for titulo, modulos in grupo.items():
                    for modulo in modulos:
                        if "Extras" in modulo:
                            del modulo["Extras"]
                            alterado = True

            # Salva o arquivo novamente apenas se tiver removido algo
            if alterado:
                with open(caminho_arquivo, 'w', encoding='utf-8') as f:
                    json.dump(conteudo, f, ensure_ascii=False, indent=2)
                print(f'Removido "Extras" de {nome_arquivo}')
            else:
                print(f'Nenhuma alteração em {nome_arquivo}')

        except Exception as e:
            print(f"Erro ao processar {nome_arquivo}: {e}")