FROM node:10

LABEL "com.github.actions.name"="Deploy Micronaut Docs to GitHub Pages"
LABEL "com.github.actions.description"="This action will handle the building and deploying process of your project to GitHub Pages."
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="http://github.com/micronaut-projects/micronaut-docs-deploy"
LABEL "homepage"="http://github.com/micronaut-projects/micronaut-docs-deploy"
LABEL "maintainer"="Graeme Rocher"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
