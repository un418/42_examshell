/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   repeat_alpha.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: adaferna <adaferna@student.42lisboa.com>   +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/06/22 15:46:57 by adaferna          #+#    #+#             */
/*   Updated: 2026/06/22 17:46:30 by adaferna         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include<unistd.h>

int is_letter(char s)
{
	if ((('a' <= s && s <= 'z')) 
	||   ('A' <= s && s <= 'Z'))
		return (1);
	return(0);
}

int get_letter_index(char s)
{
	char start;
	if ('a' <= s && s <= 'z')
		start = 97;
	if ('A' <= s && s <= 'Z')
		start = 65;
	return (s - start);
}


int main (int argc, char **argv)
{
	int n;
	char *str;

	if (argc == 2)
	{
		str = argv[1];
		while (*str)
		{
			if (is_letter(*str))
			{
				n = get_letter_index(*str);
				while (n > 0)
				{
					write(1, &*str, 1);
					n--;
				}
				
			}
			write(1, &*str, 1);
			str++;
		}
	}
	write(1, "\n", 1);
}