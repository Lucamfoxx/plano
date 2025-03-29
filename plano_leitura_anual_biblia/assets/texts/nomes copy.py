import os
import json
import re

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
            if isinstance(valor, str):
                valor_limpo = valor.replace('\n', '')
                valor_formatado = re.sub(r'(?<!\n)(\d+\.)', r'\n\1', valor_limpo)
                conteudo[chave] = valor_formatado
                alterado = True

        # Se foi alterado, sobrescreve o arquivo
        if alterado:
            with open(caminho_arquivo, 'w', encoding='utf-8') as f:
                json.dump(conteudo, f, ensure_ascii=False, indent=2)

print("✅ Todos os arquivos JSON foram atualizados: quebras de linha removidas e quebras adicionadas antes de números seguidos de ponto.")