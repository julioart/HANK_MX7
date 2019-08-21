echo 'push and save results'

cd ../..

cd FortranOutputDir/MXtry7/

git add .

git commit -m "Udapted results"

git push -u origin master

# for saving user name and password in local repository
# git config credential.helper store
