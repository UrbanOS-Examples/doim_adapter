library(
    identifier: 'pipeline-lib@4.3.4',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

def image
def doStageIf = scos.&doStageIf
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)
def doStageUnlessRelease = doStageIf.curry(!scos.changeset.isRelease)
def doStageIfPromoted = doStageIf.curry(scos.changeset.isMaster)

node('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageUnlessRelease('Build') {
            image = docker.build("scos/doim-adapter:${env.GIT_COMMIT_HASH}")
        }

        doStageIfPromoted('Deploy Latest') {
            scos.withDockerRegistry {
                image.push()
                image.push('latest')
            }
        }

        doStageIfRelease('Deploy Release') {
            def releaseTag = env.BRANCH_NAME

            scos.withDockerRegistry {
                image = scos.pullImageFromDockerRegistry("scos/doim-adapter", env.GIT_COMMIT_HASH)
                image.push(releaseTag)
            }
        }
    }
}
