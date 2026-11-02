import pikepdf, sys
src, dst = sys.argv[1], sys.argv[2]
pdf = pikepdf.open(src)
pdf.Root.Lang = pikepdf.String('fr-FR')
lib = {'tel:': 'Appeler le ', 'mailto:': 'Écrire à ', 'https://www.linkedin.com': 'Profil LinkedIn de Vincent de la Fonchais'}
for a in [a for pg in pdf.pages for a in pg.get('/Annots', [])]:
    if a.Subtype == '/Link' and '/A' in a and '/URI' in a.A:
        u = str(a.A.URI)
        if u.startswith('tel:'): t = 'Appeler le 06 63 02 63 57'
        elif u.startswith('mailto:'): t = 'Écrire à ' + u[7:]
        elif 'ifprofs' in u: t = 'Site IFprofs (ifprofs.org)'
        else: t = 'Profil LinkedIn de Vincent de la Fonchais'
        a.Contents = pikepdf.String(t)
with pdf.open_metadata() as m:
    m['dc:title'] = 'CV – Vincent de la Fonchais, consultant et auditeur en accessibilité numérique'
    m['dc:creator'] = ['Vincent de la Fonchais']
    m['dc:language'] = ['fr-FR']
pdf.save(dst)
