# Git-Deploy

Git-Deploy is a collection of shell scripts for making a deployment pipeline when all you have is a bare Git repo. It uses a post-receive hook, a named pipe and a service to place your project files to their proper destinations.

## structure
For permissions reasons, git-deploy is split into 2 parts: the hook and the listener.
The hook is usually run as the `git` user, meaning it doesn't have write access to any of the directories you would usually want to deploy to, like `/var/www/html` or `/home/mysite/public_html`.
To get around this, a simple bash service creates a named pipe and listens to it for deployment instructions. The service runs as root, so it can place the files where they need to go.

## Requirements
- [git](https://git-scm.com/), necessary for your bare repo and for running the hook
- [jq](https://stedolan.github.io/jq/) for parsing the JSON config file

an easy way to install these dependencies: is to `cat` the file into your package manager. Example:
```bash
$ sudo yum install $( cat ./INSTALL )
```

## Installation
- Copy this project's contents into a file structure of your choice, usually `/opt/git-deploy`
- link `git-deploy.service.sh` into your binaries folder for it to be accessible from anywhere, usually `/usr/sbin` or  `/usr/local/sbin`
  ```sh
  $ sudo chmod +x /opt/git-deploy/hooks/post-receive
  $ sudo chmod +x /opt/git-deploy/git-deploy.service.sh
  $ sudo ln -s /opt/git-deploy/git-deploy.service.sh /usr/local/sbin/git-deploy
  ```
- install the service file
  - [systemd](https://en.wikipedia.org/wiki/Systemd#Adoption)
    ```sh
    $ sudo ln -s /opt/git-deploy/systemd/git-deploy.service /etc/systemd/system/git-deploy.service
    ```
- enable and start the service
  ```sh
  $ sudo systemctl enable git-deploy
  $ sudo systemctl start git-deploy
  ```

## Configuration
The `git-deploy.config.json` file lives in your bare git repo (e.g. `/home/git/project-owner/project.git/`, the same as the working directory for your git-hooks), allowing for per-project configuration. If a config file isn't found there, it'll check its own directory and use that.

```js
{
  // base url of your repo, used for constructing the Merge Request link
  "repoURL": "https://gogs.example.com",

  // user and group to which the pipe belongs, defines who'll be able to write to the pipe
  "deployUser": "git",
  "deployGroup": "www-data",

  // where to keep the process' pipe. Usually this doesn't need to change
  "deployPipe": "/tmp/git-deploy.pipe",

  // should the app track updates, and if so which branch?
  "trackUpdates": true,
  "trackBranch": "master",

  // Deployment definitions, targets.[index] refers to branch name
  "targets": {
    "master": {
      // user and group to `chown` the deployed files to, useful for cPanel installs where a given site has its own user
      "user": "git",
      "group": "www-data",

      // target folder for this branch. E.g. `/home/siteuser/public_html` or `/var/www/html`
      "folder": "/home/test/public_html/project_subfolder/or/something/{repoName}",

      // url to the project, can be used in scripts to e.g. invalidate cache
      "url": "https://prod.url.to/my/project",

      // more hooks for scripts
      "pre-deploy": "/path/to/file",
      "post-deploy": "/path/to/file --url {url}"
      ... // feel free to define your own keys, they'll be made accessible to your scripts through template substitution
    },
    "develop": { ... }
  }
}
```

## Usage
First, install the hook in a repo you want deployed
- if all you have is a bare git repo, you can link to the hook in the `./hooks` folder
  ```bash
  $ ln -s /path/to/your/git/repo/hooks/post-receive /opt/git-deploy/post-receive
  ```
- if you have access to something like [Gogs](https://gogs.io/docs), you can include the hook in the project's settings: "Git Hooks => Post-Receive"
  This snippet should be enough for most use cases.
  ```bash
  #!/usr/bin/env bash
  /opt/git-deploy/hooks/post-receive <&0
  ```

## Limitations
- If you're using Gogs, Merge Requests don't fire hooks. You'll want to merge and push manually for the post-receive hook to fire.

## Contributing
Pull requests are welcome! Right now it's set up for Gogs and Systemd, and broader support is a major goal.
Please make sure to update tests as appropriate.

## Q&A
- **Q:** Do you dogfood?
  **A:** Yes, these are the scripts I personally use for deployment when a CI/CD infrastructure isn't available

## License
[MIT](https://choosealicense.com/licenses/mit/)
