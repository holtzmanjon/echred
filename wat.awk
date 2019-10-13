#{print $1, $6, $7, $6+824*$7, $10/4, $11/4, $18, ($10+$11)/8+2, $18/$7/2.5}
#{printf("%s %8.0f %8.0f %8.4f\n", $1, ($10+$11)/8+2, $18, $7)}
{printf("<tr class=\"bodytext\">\n  <td><div align=\"center\">%s</div></td>\n  <td><div align=\"center\">%8.0f</td>\n  <td><div align=\"center\">%8.0f</div></td>\n  <td><div align=\"center\">%8.4f</div></td>\n", $1, ($10+$11)/8+2, $18, $7)}
