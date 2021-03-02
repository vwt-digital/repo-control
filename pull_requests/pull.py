import logging
import argparse

from github import Github
from github import GithubException
from collections import Counter

logging.basicConfig(level=logging.INFO, format='%(levelname)7s: %(message)s')


def create_pull_request(repo):
    """Creates a pull request from develop to master"""

    try:
        return repo.create_pull(title="Development to production", body="", head="develop", base="master")
    except GithubException:
        print("A pull request already exist for this repo {}".format(repo.name))


def get_most_common(list):
    """Returns the most common element from a list"""

    counter = Counter(list)
    common = counter.most_common(1)

    return common[0][0]


def parse_args():
    """A simple function to parse command line arguments"""

    parser = argparse.ArgumentParser(description='Create pull request for a Github organization')
    parser.add_argument('-t', '--token',
                        required=True,
                        help='github access token')
    parser.add_argument('-o', '--organization',
                        required=True,
                        help='github organization name')
    parser.add_argument('-r', '--reviewer',
                        required=True,
                        help='github backup reviewer')
    return parser.parse_args()


def main(args):

    git = Github(args.token)
    usr = git.get_user()
    org = git.get_organization(args.organization)

    for repo in org.get_repos():

        logging.info("Checking repo {}".format(repo.name))

        pull_request = create_pull_request(repo)

        if pull_request:

            logging.info(" + Opened pull request")

            commits = pull_request.get_commits()
            if commits:
                authors = [commit.author.login for commit in commits]
                assignee = get_most_common(authors)

                if assignee == usr.login:  # Check if assignee is current GitHub user
                    assignee = args.reviewer

                pull_request.create_review_request(reviewers=[assignee])

                logging.info(" + Assigned {} to pull request".format(assignee))
            else:
                logging.error(" + No commits found for pull request")


if __name__ == '__main__':
    main(parse_args())
