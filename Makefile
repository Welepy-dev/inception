# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: marcsilv <marcsilv@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/04/13 03:51:14 by marcsilv          #+#    #+#              #
#    Updated: 2026/04/13 03:52:25 by marcsilv         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all:
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress
	docker compose -f srcs/docker-compose.yml up --build -d

clean:
	docker compose -f srcs/docker-compose.yml down

fclean: clean
	docker compose -f srcs/docker-compose.yml down --volumes --rmi all
	sudo rm -rf /home/$(USER)/data/mariadb
	sudo rm -rf /home/$(USER)/data/wordpress

re: fclean all
