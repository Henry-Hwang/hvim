import os

def walkfiles(dir):
        for root, dirs, files in os.walk(dir):
                #for f in files:
                #       print(os.path.join(root, f))
                for d in dirs:
                        print(os.path.join(root, d))
def update_dirs(dir):
        model = "cd @DIR ; git remote update ; cd -"
        dirs = os.listdir(dir)
        for d in dirs:
                if os.path.isdir(d):
                        model_t = model.replace("@DIR", d)
                        print(model_t)
                        os.system(model_t)
def main():
        #walkfiles(".")
        update_dirs(".")

if __name__ == '__main__':
        main()

