SparkleFormation on AWS CloudFormation
====================
The goal of this repo is to demonstrate an implementation of [SparkleFormation](https://github.com/sparkleformation/sparkle_formation) against AWS CloudFormation. This README serves as a tutorial-style walkthrough of how to write a specific SparkleFormation implementation and is designed for someone that is just looking to see SparkleFormation "do something" and isn't quite interested in the nitty gritty.

This example implementation will include the deployment of two Autoscaling groups (one webserver ASG and a db ASG) which can talk to each other, with the webserver ASG behind an Elastic Load Balancer.

* The ELB ports will be able to be defined at deploy time.
* The ELB will be in its own stack, so the ASG behind it can be swapped out. (so no need to adjust DNS)

We'll create the stack that contains the ELB first and then we'll create the application stack and use outputs from the ELB stack to set parameters on the application stack at deploy time. Pretty slick stuff.

# Setting Up SparkleFormation

While there is support forthcoming for provisioning without the `knife-cloudformation` gem, for this walkthrough we're going to [use that gem for provisioning](https://github.com/sparkleformation/sparkle_formation/blob/develop/docs/provisioning.md#knife-cloudformation-setuphttps://github.com/sparkleformation/sparkle_formation/blob/develop/docs/provisioning.md#knife-cloudformation-setup). `knife-cloudformation` is a [Chef](http://chef.io)-related tool that will provision to CloudFormation and can also use SparkleFormation templates to do so.

Install both the `knife-cloudformation` and `sparkle_formation` Ruby Gems by doing either of the following. Since the `knife-cloudformation` requires `sparkle_formation`, you'll get both.

Execute the following:

```
gem install knife-cloudformation
```

or with Bundler by doing a `bundle install` with the following in your `Gemfile`:

```
gem 'knife-cloudformation'
```

Assuming you have your AWS credentials already loaded into your environment, make sure you have the following to your `.chef/knife.rb`: (it's already included in the repo)

```
knife[:aws_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']

[:cloudformation, :options].inject(knife){ |m,k| m[k] ||= Mash.new }
knife[:cloudformation][:options][:disable_rollback] = true
knife[:cloudformation][:options][:capabilities] = ['CAPABILITY_IAM']
knife[:cloudformation][:processing] = true
knife[:cloudformation][:credentials] = {
  :aws_region => knife[:region],
  :aws_access_key_id => knife[:aws_access_key_id],
  :aws_secret_access_key => knife[:aws_secret_access_key]
}
```

Finally, to be able to log in to your AWS instances in this demonstration, you'll need to have a key pair on AWS called `sparkleinfrakey`.

That's it, we're ready to code.

# The Sparkles
For a more in-depth explanation of what the "Sparkles" are, see ["Building Blocks"](https://github.com/sparkleformation/sparkle_formation/blob/develop/docs/building-blocks.md) in the main SparkleFormation documentation.

What are we doing here? Well, in the end we just want to produce one JSON file for each stack that contains a hash that we'll send to the AWS CloudFormation API. It's just that we don't want to write JSON--anymore...ever. At least for CloudFormation :) So we're breaking up all the things that go into that JSON hash into several, more manageable files. This brings *many* benefits, but again, see the main docs for an explanation.

# The ELB Stack

Let's create our ELB stack. Our [*template* file is very simple](cloudformation/code_examples/app_load_balancer.rb). It just has a description and a dynamic call which adds the [`load_balancer` *dynamic*](cloudformation/dynamics/load_balancer.rb). This `load_balancer` dynamic is a reusable piece of code that allows you to deploy an ELB with user-defined parameters at deploy time, with optional defaults. It can be re-used with minimal effort to deploy many ELBs all with different configurations. This sure beats writing JSON multiple times for different ELB deployments or copy/pasting pieces from one JSON file into another.

To create our ELB stack, do:

```
knife cloudformation create my-sf-elb --processing
```

Then choose `1` from the first menu, and then `2` to deploy the `app_load_balancer` template to the AWS CloudFormation API. You'll be prompted for several values. For this demonstration, you can just accept all the default values. If you change these, you'll just have to make sure that you make the corresponding changes when you deploy the application stack. Let's move on to that.

## The Base [Component](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#components)
The first piece we're going to put together is a static [*component*](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#components) which will contain info/data that we'll want to be the same across _many_ CloudFormation stacks we build. Since I want this walkthrough to stay up to date with the changes to files in this repo, I'm not embedding code examples here, I'll link to them in the repo.

So, [check out the only component in this implementation, called `base`](cloudformation/components/base.rb). You'll notice that it contains just two resources and one parameter that have to do with the AWS keypair, the AWS IAM user and that user's access key. These are the only things we want the same across all our stacks, and that's why we're putting it into a _static *component*_. Again, this sure beats pulling these key pieces of code out of one JSON file and copying them into another.

## The [Registries](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#registries)
We're going to create three [registries](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#registries):

* [`apt_get_update`](cloudformation/registry/apt_get_update.rb)
* [`mysql_install`](cloudformation/registry/mysql_install.rb)
* [`nginx_install`](cloudformation/registry/nginx_install.rb)

Pretty self-explanatory. We're going to use the `apt_get_update` registry for both AutoScaling groups and we'll use the `mysql_install` and the `nginx_install` registries for the database and application AutoScaling groups, respectively. You'll see how we use these below in the *template*. Once again, no copy pasta!

## The [Dynamics](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#dynamics)
A [*dynamic*](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/building-blocks.md#dynamics) usually corresponds to one or more resources and is, again re-usable, but it is dynamic in the sense that you can deploy it with a unique configuration. You'll notice on the [first (non-commented) line of each dynamic's `do` statement](cloudformation/dynamics/auto_scaling_group.rb#L13), there is an iterator called [`_config`](https://github.com/sparkleformation/sparkle_formation/blob/develop/docs/building-blocks.md#dynamics). Each dynamic can receive several values through this `_config` hash to create a unique configuration of a given resource. See the Template section below for how these dynamics are implemented.

There are several re-usable dynamics that will compose our application stack:

* [`auto_scaling_group`](cloudformation/dynamics/auto_scaling_group.rb) - We'll re-use to create both of the `AWS::AutoScaling::AutoScalingGroup`resources in this implementation
* [`launch_configuration`](cloudformation/dynamics/launch_configuration.rb) - We'll re-use to create the `AWS::AutoScaling::LaunchConfiguration` resources that will be associated with each of the respective `AWS::AutoScaling::AutoScalingGroup` resources
* [`security_group`](cloudformation/dynamics/security_group.rb) - We'll re-use to create two different `AWS::EC2::SecurityGroup` resources
* [`security_group_ingress`](cloudformation/dynamics/security_group_ingress.rb) - We'll reuse to create the individual `AWS::EC2::SecurityGroupIngress` rules for each AWS `AWS::EC2::SecurityGroup` resource.

## The Template
Our [*template* is the "highest level" Sparkle](cloudformation/code_examples/db_app_template_example.rb), if you will. It brings together all of the different aforementioned pieces. For example, take a look at [how the `launch_configuration` dynamic is implemented](cloudformation/code_examples/db_app_template_example.rb#L39) in the template. If you are a Chef user, you may recognize the pattern. When the dynamic is called, it's given a name, `db` or `app`. Starting on the second line of that block, you'll see that there are several other values that are being passed in to the dynamic. As mentioned earlier, the dynamic then accesses these values through the `_config` hash iterator. This pattern is quite similar to how an LWRP is used in Chef. It is named dynamically and then certain attributes are passed to it for a unique deployment of the given resource.

Notice, too, that the [registries we created earlier are 'inserted' in the resource definitions](cloudformation/code_examples/db_app_template_example.rb#L47) for each LaunchConfiguration.

You can also note that when the `auto_scaling` group dynamic is being called to deploy both the `app` and `db` ASGs, the `launch_configuration_name` value being passed through `_config` is referencing the corresponding LaunchConfiguration for each ASG using the CloudFormation's `Ref` function. See [here for more on using CF functions in SparkleFormation](https://github.com/sparkleformation/sparkle_formation/blob/master/docs/functions.md#intrinsic-functions).

So, now we're going to deploy this application stack. But how are we going to associate the ELB we've already created? One way would be to log into the AWS console or fire up the AWS CLI and find the ID of the ELB we created in the first step. But an easier way would be to consume that data automatically. So we're just going to [apply the outputs from the ELB stack we created to this new stack](https://github.com/sparkleformation/sparkle_formation/blob/develop/docs/provisioning.md#applying-stacks) so they can automatically play nice.

To do this, we at least need the name of the ELB stack we created earlier, which is `my-sf-elb`. Here we go:

```
knife cloudformation create my-app-stack --processing --apply-stack my-sf-elb
```

Choose `1` and then `1`. You'll know that this magic "apply" is working when you accept all the defaults and get to the last one. The default value you're shown for the `My App Stack Load Balancer Resource Name` parameter should automatically have the correct name for your ELB. This value was found as an output of your `my-sf-elb` and passed to the parameter of the same name in your application stack. Just press enter to accept it. 

When your app stack comes up successfully, you should have two instances for each of your `app` and `db` AutoScaling groups with the `app` ASG load balanced. The app instances should also be able to access the db nodes on their private IP addresses on port 3306.

By the way, if you want to avoid prompts for parameters (which we're accepting all defaults for this demo anyway) you can do this by using the `--file` and `--defaults` options.

```
knife cloudformation create my-app-stack --processing --file cloudformation/code_examples/db_app_template_example.rb --defaults
```
