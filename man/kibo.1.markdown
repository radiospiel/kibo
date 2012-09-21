kibo(1) -- manage heroku applications
================================================

## SYNOPSIS

`kibo [options] create`<br>
`kibo [options] deploy`<br>
`kibo [options] spinup`<br>
`kibo [options] spindown`<br>
`kibo [options] reconfigure`<br>
`kibo [options] generate`

## DESCRIPTION

kibo manages multiple application roles on single heroku dynos.

## DESCRIPTION

Kibo is a perfect addition to Procfile based deployment on heroku.com.
While heroku itself provides adequate tools to manage a single application
on multiple dynos, Kibo adds tools to manage multiple application roles 
on single dynos with automatic instance provisioning.

The application roles are read from the Procfile (see foreman(1)). 
The concurrency options - i.e. the number of applications to run
each role - is read from the Kibofile.

## INSTANCE PROVISIONING

Each instance gets automatically configured using `heroku config. kibo
sets the environment variables INSTANCE, RAILS_ENV and RACK_ENV to reflect
instance role and number and runtime environment.

    INSTANCE="kibo-staging-web1"
    RAILS_ENV="staging"
    RACK_ENV="staging"

## GLOBAL OPTIONS

The following options control how kibo is run:

  * `-e`, `--environment`:
    Set the target environment. Defaults to "staging"

  * `-k`, `--kibofile`:
    Specify an alternate Kibofile to use.

  * `-p`, `--procfile`:
    Specify an alternate Procfile to use.

## Kibofile

A Kibofile scaffold can be generated via `kibo generate`. The following is an example:

    kibo:
      # The email of the heroku account to create app instances on heroku.
      heroku: user@domain.com
      # You instances will be called 'kiboex-staging-web0', 'kiboex-production-worker0', etc.
      namespace: kibo
    defaults:
      procfile: Procfile.other
      web: 1
      worker: 1
    production:
      web: 1
      worker: 2

This defines the roles "web" and "worker", which are running at one resp. two instances in
the "production" environment.  

## Example session

This is a session using the example Kibofile from above:

    # creates the heroku applications "kibo-production-web1",  
    # "kibo-production-worker1", and "kibo-production-worker2". 
    kibo -e production create 

    # deploy all applications.
    kibo -e production deploy 

    # start all instances
    kibo -e production spinup
    
    # stop all instances
    kibo -e production spindown 
    
## COPYRIGHT

Kibo is Copyright (C) 2012 Enrico Thierbach <http://radiospiel.org>


[SYNOPSIS]: #SYNOPSIS "SYNOPSIS"
[DESCRIPTION]: #DESCRIPTION "DESCRIPTION"
[DESCRIPTION]: #DESCRIPTION "DESCRIPTION"
[INSTANCE PROVISIONING]: #INSTANCE-PROVISIONING "INSTANCE PROVISIONING"
[GLOBAL OPTIONS]: #GLOBAL-OPTIONS "GLOBAL OPTIONS"
[Kibofile]: #Kibofile "Kibofile"
[Example session]: #Example-session "Example session"
[COPYRIGHT]: #COPYRIGHT "COPYRIGHT"


[kibo(1)]: kibo.1.html
