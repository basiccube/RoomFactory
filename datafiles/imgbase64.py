#==================================
# imgbase64
#
# encodes a png file to base64
# -vivian
#==================================

import base64, os, sys, argparse

parser = argparse.ArgumentParser(prog='imgbase64', usage='%(prog)s file')
parser.add_argument("file", default="", help="image file name")
args = parser.parse_args()

filename = os.path.splitext(args.file)[0]
print("name : %s" % (filename))

def create_base64_file(path):
    with open(path + ".png", "rb") as img:
        print("encoding file %s" % (path))
        imgdata = base64.b64encode(img.read()).decode()
        bstr = "data:image/png;base64," + imgdata
        
        with open(path + ".txt", "w") as txtimg:
            txtimg.write(bstr)

if os.path.isdir(filename):
    for path, dirs, files in os.walk(filename):
        print("directory : %s" % (path))
        print("file count : %s" % (len(files)))
        
        encodedcount = 0
        for file in files:
            fullpath = os.path.join(path, file)
            splitpath = os.path.splitext(fullpath)
            
            if (splitpath[1] == ".png"):
                create_base64_file(splitpath[0])
                encodedcount += 1
        print("encoded files : %s" % (encodedcount))
else:
    create_base64_file(filename)