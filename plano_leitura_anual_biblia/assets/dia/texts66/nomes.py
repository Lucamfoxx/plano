import os
import json

# Caminho da pasta onde o script está localizado
pasta_atual = os.path.dirname(os.path.abspath(__file__))

# Percorre todos os arquivos JSON na pasta
for nome_arquivo in os.listdir(pasta_atual):
    if nome_arquivo.endswith(".json"):
        caminho_arquivo = os.path.join(pasta_atual, nome_arquivo)
        with open(caminho_arquivo, 'r', encoding='utf-8') as f:
            conteudo = json.load(f)

        alterado = False

        # Para cada valor no dicionário, remove as quebras de linha
        for chave in conteudo:
            valor = conteudo[chave]
            if isinstance(valor, str) and '\n' in valor:
                conteudo[chave] = valor.replace('\n', '')
                alterado = True

        # Se foi alterado, sobrescreve o arquivo
        if alterado:
            with open(caminho_arquivo, 'w', encoding='utf-8') as f:
                json.dump(conteudo, f, ensure_ascii=False, indent=2)

print("✅ Todos os arquivos JSON foram atualizados e as quebras de linha foram removidas dos valores.")