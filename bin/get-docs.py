import sys
from webbrowser import open

docs = {
    'php': 'https://php.net/',
    'py': 'https://docs.python.org/3/search.html?q='
}

args = sys.argv

if len(args)<2:
    pass
elif len(args)<3:
    open('https://google.com/search?q=' + args[1])
elif args[1] in docs:
    open(docs[args[1]]+args[2])
else:
    print('No documentation for', args[1], 'found.')