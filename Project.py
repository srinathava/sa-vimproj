class Project:
    def __init__(self):
        # Everything under this directory is considered part of this
        # project
        self.path = ''

        # The "language" of the current project.
        self.lang = 'C'

        # A list of projects which this project depends on
        self.dependencies = []

        # The path to the .h file this project exports to others.
        self.exportHeader = ''

        # A list of custom .h files which are included by this project
        # using some "hidden" means which I cannot figure out
        # automatically.
        self.customIncludes = []
