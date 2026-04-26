import os

def afficher_arborescence(chemin, prefix=""):
    elements = sorted(os.listdir(chemin))
    
    for index, element in enumerate(elements):
        chemin_complet = os.path.join(chemin, element)
        est_dernier = index == len(elements) - 1

        branche = "└── " if est_dernier else "├── "
        icone = "📁 " if os.path.isdir(chemin_complet) else "📄 "
        
        print(prefix + branche + icone + element)

        if os.path.isdir(chemin_complet):
            nouveau_prefix = prefix + ("    " if est_dernier else "│   ")
            afficher_arborescence(chemin_complet, nouveau_prefix)

if __name__ == "__main__":
    dossier_courant = os.getcwd()
    print(f"📂 {dossier_courant}")
    afficher_arborescence(dossier_courant)