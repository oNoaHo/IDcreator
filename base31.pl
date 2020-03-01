
#!/usr/bin/perl -w

###
# @script Script that calculate an ID avoiding baaad names :D
# @author Christian Mueller <christian.mueller15@bosch.com>
# @version $Id: Coding-Standards.sgml,v 0.1 2020/03/01 
###

use strict;
use warnings;

################
# SUBROUTINES
################

#ENCODE
#convert a decimal number into LeafID
sub encode{
    my $decimal=shift || return "No number to encode";
    my $charsetb=shift || return "no standard charset";
    my $charsets=shift || return "no reduced charset";
    my $string = '';
    $decimal=strip($decimal);
    if ($decimal !~/^\d{1,16}$/){
        return 'Value must be a positive integer';
    }
    do {
        if(((length($string)+1) % 4) == 0){
            #get remainder after dividing
            my $remainder = $decimal % length($charsets);
            # get CHAR from array
            my $char    = substr($charsets, $remainder, 1);
            $string     = "$char$string";
            $decimal    = ($decimal - $remainder) / length($charsets);
        }
        else{
            my $remainder = $decimal % length($charsetb);
            my $char      = substr($charsetb, $remainder, 1);
            $string    = "$char$string";
            $decimal   = ($decimal - $remainder) / length($charsetb);
        }
    }
    while ($decimal > 0);
    return $string;
}

#DECODE
#convert a LeafID number into decimal number
sub decode{
    my $string=shift;
    my $charsetb=shift || return "no standard charset";
    my $charsets=shift || return "no reduced charset";
    if(!length(strip($string))){return "No valid string to decode";}
    #uppercase the string
    $string=uc($string);
    my $decimal = 0;
    do {
        my $modulo = length($string) % 4;
        #extract leading character
        my $char   = substr($string, 0, 1);
        #drop leading character
        $string = substr($string, 1);
        #get offset in $charset
        if($modulo == 0){
            my $pos = index($charsets, $char);
            if ($pos == -1) {
                return "Illegal character ($char) in INPUT string";
            }
            $decimal = ($decimal * length($charsets)) + $pos;
        }
        else{
            my $pos = index($charsetb, $char);
            if ($pos == -1) {
                return "Illegal character ($char) in INPUT string";
            }
            $decimal = ($decimal * length($charsetb)) + $pos;
        }
    } 
    while(length($string));
    return $decimal;
}

sub strip{
    #usage: $str=strip($str);
    #info: strips off beginning and endings returns, newlines, tabs, and spaces
    my $str=shift;
    if(length($str)==0){return;}
    $str=~s/^[\r\n\s\t]+//s;
    $str=~s/[\r\n\s\t]+$//s;
    return $str;
}
###############
sub abort{
    my $msg=shift;
    print "$msg\n";
    exit 1;
}

sub main{
    #maximum character string for $charsetb is 36 characters ([0-9][a-z])
    #exclude characters B, I, L, O, S and Z removes problems that may arise where a
    #number encoded spells something not very nice
    my $charsetb = '0123456789ACDEFGHJKMNPQRTUVWXY';
    my $charsets = '0123456789';
    my $num=shift || abort(
        "enter a number between 1 and 7289999999\ne.g. $0 91530"
    );
    if ($num !~/^\d{1,16}$/){abort('Number must be a positive integer');}
    print "Number: $num\n";
    my $enc=encode($num, $charsetb, $charsets);
    print "LeafID: $enc\n";
    my $dec=decode($enc, $charsetb, $charsets);
    print "Decoded: $dec\n";
    exit;
}
main($ARGV[0]);