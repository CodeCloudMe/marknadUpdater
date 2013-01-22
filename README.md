# Rails Sample App on OpenShift #
Quickstart rails application for openshift.

The easiest way to install this application is to use the [OpenShift
Instant Application][template]. If you'd like to install it
manually, follow [these directions](#manual-installation).

## OpenShift Considerations ##
These are some special considerations you may need to keep in mind when
running your application on OpenShift.

### Database ###
Your application is configured to use your OpenShift database in
Production mode.
Because it addresses these databases based on [OpenShift Environment
Variables](http://red.ht/NvNoXC), you will need to change these if you
want to use your application in Production mode outside of
OpenShift.

### Assets ###
Your application is set to precompile the assets every time you push
to OpenShift. Any assets you commit to your repo will be preserved
alongside those which are generated during the build.

### Security ###
Since these quickstarts are shared code, we had to take special
consideration to ensure that security related configuration variables
was unique across applications.
To accomplish this, we modified some of the configuration files (shown
in the table below).
Now instead of using the same default values, your application will
generate it's own value using the `initialize_secret` function from `lib/openshift_secret_generator.rb`.

This function uses a secure environment variable that only exists on
your deployed application and not in your code anywhere.
You can then use the function to generate any variables you need.
Each of them will be unique so `initialize_secret(:a)` will differ
from `initialize_secret(:b)` but they will also be consistent, so any
time your application uses them (even across reboots), you know they
will be the same.

##### Modified Files #####

<table>
  <tr>
    <th>File</th>
    <th>Variable</th>
  </tr>
  <tr>
    <td>config/initializers/secret_token.rb</td> 
    <td>Railsapp::Application.config.secret_token</td>
  </tr>
  <tr>
    <td>config/initializers/session_store.rb</td>
    <td>Railsapp::Application.config.session_store</td>
  </tr>
</table>

## Manual Installation ##

1. Create an account at http://openshift.redhat.com/

1. Create a rails application

    ```
    rhc app create -a railsapp -t ruby-1.9
    ```

   **Note:** To support Ruby 1.8,
   ```
   +++ config/initializers/wrap_parameters.rb
   @@ -5,7 +5,7 @@
    
     # Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
      ActiveSupport.on_load(:action_controller) do
      -  wrap_parameters format: [:json]
      +  wrap_parameters ({:format => [:json]})
       end
  ```



1. Add mysql support to your application

    ```
    rhc cartridge add -a railsapp -c mysql-5.1
    ```

1. Add this upstream Rails quickstart repository

    ```
    cd railsapp
    git remote add upstream -m master git://github.com/openshift/rails-example.git
    git pull -s recursive -X theirs upstream master
    ```

1. Push your new code

    ```
    git push
    ```

1. That's it! Enjoy your new Rails application!


[template]: https://openshift.redhat.com/app/console/application_types/rails

License
-------

This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to CC0 (http://creativecommons.org/publicdomain/zero/1.0/)
