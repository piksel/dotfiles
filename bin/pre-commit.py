from lxml import etree
from os import system, path

root = ''

def main():
    root = system('git rev-parse --show-toplevel')
    
    clean_configs()
    

def clean_configs():
    
    clean_xml('npp/config.xml', [
        './FindHistory', 
        './FileBrowser',
        './History'
    ])

def clean_xml(file, patterns):
    file = path.join(root, file)
    print('Cleaning XML file ', file)
    tree = etree.parse(file)
    for pattern in patterns:
        print('  Removing pattern "', pattern, '"... ', end='', sep='')
        nodes = tree.findall(pattern)
        print('Found', len(nodes), 'node(s).')
        for node in nodes:
            node.getparent().remove(node)
     
    #etree.dump(tree)     
    notags = etree.tostring(tree, encoding='utf8', pretty_print=True)
    tree.write(file)
    print('Cleaned XML file saved.')


if __name__ == '__main__':
    main()