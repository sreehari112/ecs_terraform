
resource "aws_alb" "ecs-load-balancer" {
    name                = "ecs-load-balancer"
    security_groups     = ["${aws_security_group.test_public_sg.id}"]
    subnets             = ["${aws_subnet.test_public_sn_01.id}", "${aws_subnet.test_public_sn_02.id}"]

    tags {
      Name = "ecs-load-balancer"
    }
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${aws_vpc.test_vpc.id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "ecs-target-group"
    }
}

resource "aws_alb_target_group" "ecs-target-group-https" {
    name                = "ecs-target-group-https"
    port                = "443"
    protocol            = "HTTPS"
    vpc_id              = "${aws_vpc.test_vpc.id}"

    health_check {
                path = "/healthcheck"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 2
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200-308"
    }

    tags {
      Name = "ecs-target-group-https"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
        type             = "forward"
    }
}
resource "aws_lb_listener" "alb-listener-https" {
  load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ecs-target-group-https}"
  }
}
