import os
import json

# Caminho da pasta onde estão os JSONs originais
caminho_pasta = "assets/modulos"

# Caminho da nova pasta onde os arquivos por dia serão salvos
pasta_saida = "novos_dias"
os.makedirs(pasta_saida, exist_ok=True)

# Função que expande "1-3" em [1, 2, 3]
def expandir_capitulos(capitulos_str):
    resultado = []
    partes = capitulos_str.replace("–", "-").replace("—", "-").split(',')
    for parte in partes:
        if '-' in parte:
            inicio, fim = map(int, parte.strip().split('-'))
            resultado.extend(range(inicio, fim + 1))
        else:
            resultado.append(int(parte.strip()))
    return resultado

# Lê todos os arquivos .json da pasta original
for nome_arquivo in os.listdir(caminho_pasta):
    if nome_arquivo.endswith(".json"):
        caminho_arquivo = os.path.join(caminho_pasta, nome_arquivo)
        with open(caminho_arquivo, 'r', encoding='utf-8') as f:
            conteudo = json.load(f)

        for categoria in conteudo:
            for entrada in conteudo[categoria]:
                dia = entrada.get("Dia")
                livro1 = entrada.get("Livro")
                cap1 = entrada.get("Capítulo")
                livro2_e_cap = entrada.get("Livro e Capítulo", "")

                novo_json = {}

                # Livro 1
                if livro1 and cap1:
                    for cap in expandir_capitulos(cap1):
                        novo_json[f"{livro1} {cap}"] = ""

                # Livro 2 (se tiver)
                if livro2_e_cap:
                    partes = livro2_e_cap.strip().split()
                    if len(partes) >= 2:
                        livro2 = " ".join(partes[:-1])
                        cap2 = partes[-1]
                        for cap in expandir_capitulos(cap2):
                            novo_json[f"{livro2} {cap}"] = ""

                # Salva o novo arquivo com nome "dia__XXX.json"
                nome_saida = f"dia__{dia}.json"
                caminho_saida = os.path.join(pasta_saida, nome_saida)
                with open(caminho_saida, 'w', encoding='utf-8') as f_saida:
                    json.dump(novo_json, f_saida, ensure_ascii=False, indent=2)

print("✅ Todos os arquivos foram salvos na pasta 'novos_dias'.")