from xml.dom import minidom
mydoc = minidom.parse('dummy.xml')
items = mydoc.getElementsByTagName('item')
new_items = []
for elem in items:
  if elem.attributes['name'].value == 'item1':
    new_items.append(elem.firstChild.nodeValue)
new_items
