#!/usr/bin/perl -w
use strict;

&main;

sub max($$) { return ( $_[0] > $_[1] ? $_[0] : $_[1] ); }
sub min($$) { return ( $_[0] < $_[1] ? $_[0] : $_[1] ); }
sub start_entry { print OUT '{ = '; }
sub end_entry   { print OUT '}' . "\n"; }

sub get_random_color {
    my @result = ();
    map { my $c = rand(); push( @result, $c ); undef } ( 0 .. 2 );
    push(@result,0);
    return ( \@result );
}

sub union {
    sub numerically { $a <=> $b; }
    my %kiekeboe = ();
    my @res = grep { !$kiekeboe{$_}++ } sort numerically @{ &join(@_) };
    return ( \@res );
}

sub join {
    my @res = ();
    my $i;
    foreach $i (@_) { push( @res, @{$i} ) }
    return ( \@res );
}

sub print_point {
    my $a = shift;
    map { print OUT $_; print OUT ' '; undef } @{$a};
}

sub are_connected {

    # take two vertices from @vertices and check if they are
    # adjacent.
    my @a1 = @{ $_[0] };
    my @a2 = @{ $_[1] };
    pop(@a1);
    pop(@a2);
    my @a3 = @{ &union( \@a1, \@a2 ) };

    # if they have three halfspaces in common there is a vertex
    # bv $#a3 = 4 five elements
    # bv $#a1 = 3 four elements
    # bv $#a2 = 3 four elements
    if ( $#a3 - $#a1 == $#a2 - 2 ) {
        return (1);
    }
    else {
        return (0);
    }
}

sub print_random_color {
    map { my $c = rand(); print OUT "$c "; } ( 0 .. 3 );
    print OUT "\n";
}

sub gethalfval {
    # what does this function do? 
    # $r1->[4] is 1 ?
    my $r1  = $_[0];
    my $r2  = $_[1];
    my $res =
      ( $r2->[0] ) * ( $r1->[0] ) + ( $r2->[1] ) * ( $r1->[1] ) + ( $r2->[2] ) *
      ( $r1->[2] ) + ( $r2->[4] );
    return ($res);
}

sub main {

    # the infile is
    # first three lines for the limits
    # -1 4
    # -2 2
    # 0 6
    # SO THE x lies inbetween -1 and 4, y between -2 and 2, z between 0 and 6
    # then a number of points with their radii follow
    # so
    #
    # then the deal is calculate the halfspaces with qhalf
    my (
        @interiorpoint, $midval,     $i,        $j,
        @points,        $infile,     $cmdline,  $outfile,
        $count,         $novertices, @vertices, @edges, @colors, @simplices,$nosimplices
    );
    $infile = $ARGV[0];
    my @halfspaces;
    open( IN, "< $infile" ) or die "The file $infile does not exist!\n";
    $count = 0;
    while (<IN>) {
        my @lineguy = split( ' ', $_ );
        my @entry   = ();
      SWITCH: {
          # we first read in the bounding box.
          # Each one results in two halfspaces
          # The half spaces are determined by 5 numbers
          # ax + by + cz +dw +e  >0
          # That's because the halfplanes are in 
          # dot(normal, coords) + offset <= 0
          # the offset is the last thing here
            if ( $count == 0 ) {
                push( @halfspaces, [ -1.0, 0.0, 0.0, 0.0, $lineguy[0] ] );
                push( @halfspaces, [ 1.0, 0.0, 0.0, 0.0, -1.0 * $lineguy[1] ] );
                last SWITCH;
            }
            if ( $count == 1 ) {
                push( @halfspaces, [ 0.0, -1.0, 0.0, 0.0, $lineguy[0] ] );
                push( @halfspaces, [ 0.0, 1.0, 0.0, 0.0, -1.0 * $lineguy[1] ] );
                last SWITCH;
            }
            if ( $count == 2 ) {
                push( @halfspaces, [ 0.0, 0.0, -1.0, 0.0, $lineguy[0] ] );
                push( @halfspaces, [ 0.0, 0.0, 1.0, 0.0, -1.0 * $lineguy[1] ] );
                last SWITCH;
            }
            # being over here you have a point;
            # for the point you need  to compute a weight
            my $sum =
              0.5 * $lineguy[3] * $lineguy[3] - 0.5 * $lineguy[2] * $lineguy[2]
              - 0.5 * $lineguy[1] * $lineguy[1] - 0.5 * $lineguy[0] *
              $lineguy[0];
            push( @halfspaces,
                [ $lineguy[0], $lineguy[1], $lineguy[2], -1.0, $sum ] );
        }
        $count++;
    }
    close(IN);

    # now you have the halfspaces, but you also need an interior point to
    # determine an upper point . This an upper limit for the
    # get one value to start with:
    $count =
      gethalfval(
        [ $halfspaces[0]->[4], $halfspaces[2]->[4], $halfspaces[4]->[4] ],
        $halfspaces[6] );
    foreach $j ( 6 .. $#halfspaces ) {
        # de kubus heeft in totaal acht hoekpunten
        # die moet je allemaal aflopen
        # (max, max, max)
        $count = &max(
            $count,
            &gethalfval(
                [
                    -1.0 * ( $halfspaces[1]->[4] ),
                    -1.0 * ( $halfspaces[3]->[4] ),
                    -1.0 * ( $halfspaces[5]->[4] )
                ],
                $halfspaces[$j]
            )
        );

        # (min, max, max)
        $count = &max(
            $count,
            &gethalfval(
                [
                    $halfspaces[0]->[4],
                    -1.0 * ( $halfspaces[3]->[4] ),
                    -1.0 * ( $halfspaces[5]->[4] )
                ],
                $halfspaces[$j]
            )
        );

        # (max, min, max)
        $count = &max(
            $count,
            &gethalfval(
                [
                    -1.0 * ( $halfspaces[1]->[4] ),
                    $halfspaces[2]->[4],
                    -1.0 * ( $halfspaces[5]->[4] )
                ],
                $halfspaces[$j]
            )
        );

        # (min, min, max)
        $count = &max(
            $count,
            &gethalfval(
                [
                    $halfspaces[0]->[4], $halfspaces[2]->[4],
                    -1.0 * ( $halfspaces[5]->[4] )
                ],
                $halfspaces[$j]
            )
        );

        # (max, max, min)
        $count = &max(
            $count,
            &gethalfval(
                [
                    -1.0 * ( $halfspaces[1]->[4] ),
                    -1.0 * ( $halfspaces[3]->[4] ),
                    $halfspaces[4]->[4]
                ],
                $halfspaces[$j]
            )
        );

        # (min, max, min)
        $count = &max(
            $count,
            &gethalfval(
                [
                    $halfspaces[0]->[4], -1.0 * ( $halfspaces[3]->[4] ),
                    $halfspaces[4]->[4]
                ],
                $halfspaces[$j]
            )
        );

        # (max, min, min)
        $count = &max(
            $count,
            &gethalfval(
                [
                    -1.0 * ( $halfspaces[1]->[4] ), $halfspaces[2]->[4],
                    $halfspaces[4]->[4]
                ],
                $halfspaces[$j]
            )
        );

        # (min, min, min)
        $count = &max(
            $count,
            &gethalfval(
                [
                    $halfspaces[0]->[4], $halfspaces[2]->[4],
                    $halfspaces[4]->[4]
                ],
                $halfspaces[$j]
            )
        );
    }

    # and now you have to make $count slightly
    # larger, so that you don't nasty intersections

    if ( $count > 0 ) { $count = 1.1 * $count; }
    else { $count = 0.9 * $count; }

    push( @halfspaces, [ 0, 0, 0, 1, -1.0 * $count ] );

    # now we need an interiorpoint
    # to get one we take the middle of the bounding box
    @interiorpoint = (
        0.5 * ( $halfspaces[0]->[4] ) - 0.5 * ( $halfspaces[1]->[4] ),
        0.5 * ( $halfspaces[2]->[4] ) - 0.5 * ( $halfspaces[3]->[4] ),
        0.5 * ( $halfspaces[4]->[4] ) - 0.5 * ( $halfspaces[5]->[4] )
    );

    # then we pass all the hyperplanes, and we see what the
    # value of x_0 is there
    $count = &gethalfval( \@interiorpoint, $halfspaces[6] );
    foreach $j ( 6 .. $#halfspaces - 1 ) {
        $count =
          &max( $count, &gethalfval( \@interiorpoint, $halfspaces[$j] ) );
    }
    push( @interiorpoint,
        -0.5 * ( $halfspaces[$#halfspaces]->[4] ) + 0.5 * $count );

    # now everything is set up, you have a closed polytope, and a point in it
    # call qhalf
    $outfile = $infile . '.QHALFinput';
    open( OUT, "> $outfile" );

    print OUT "4 1 \n";
    print OUT $interiorpoint[0];
    print OUT " ";
    print OUT $interiorpoint[1];
    print OUT " ";
    print OUT $interiorpoint[2];
    print OUT " ";
    print OUT $interiorpoint[3];
    print OUT "\n5\n";
    print OUT $#halfspaces + 1;
    print OUT "\n";

    foreach $i (@halfspaces) {
        print_point $i;
        print OUT "\n";
    }

    close(OUT);

    # with the Fp option you find all the intersection coordinates.
    # then you can get the edges by just checking whether
    # two intersection are adjacent
    $cmdline = 'qhalf Fv Fp < ' . $outfile . ' > ' . $infile . '.QHALFoutput';
    system($cmdline);

    # now we have the QHALF output
    # it is a polytope in the four spaces
    # we are most interested in its vertices and
    # in its one dimensional edges, these
    # need to be drawn
    # to get the vertices we need to take all quadruples of
    # halfspace, if we meet an entry with more than four
    # halfspaces
    open( IN, " < $infile" . '.QHALFoutput' );
    $count      = 0;
    $novertices = 0;
    @vertices   = ();
    while (<IN>) {
      SWITCH: {
            if ( $count == 0 ) {
                $novertices = $_;
                last SWITCH;
            }
            if ( $count > 0 && $count < $novertices + 1 ) {

                # when you're over here you get the number halfspaces numbering
                my @lineguy = split( ' ', $_ );

                # the first one is not relevant so you can drop it
                shift @lineguy;
                push( @vertices, \@lineguy );
                last SWITCH;
            }
            if ( $count > $novertices + 2 ) {
                my @lineguy = split( ' ', $_ );
                my @entry = @{ $vertices[ $count - $novertices - 3 ] };
                push( @entry, \@lineguy );
                $vertices[ $count - $novertices - 3 ] = \@entry;
            }
        }
        $count++;
    }
    close(IN);
    # pass by each pair of vertices
    @edges = ();
    foreach $count ( 0 .. $#vertices ) {
        foreach $j ( $count + 1 .. $#vertices ) {
            if ( &are_connected( $vertices[$j], $vertices[$count] ) ) {
                my @entry = ( $count, $j );
                push( @edges, \@entry );
            }
        }
    }

    # now we have all the edges and we can start thinking of a LIST
    $outfile = $infile . '.list';
    open( OUT, "> $outfile" );
print OUT << "ENDHEADER";
appearance {
 -face
 +edge
 +shadelines
 linewidth 4
}
ENDHEADER

    print OUT "LIST \n";
    start_entry;
    print OUT "VECT \n";

    # number of lines
    print OUT $#edges + 1;
    print OUT " ";

    # number of vertices, 2 foreach line
    print OUT 2 * $#edges + 2;
    print OUT " ";

    # number of colors, 1 foreach line
    print OUT $#edges + 1;
    print OUT "\n";
    foreach $j (@edges) {
        print OUT "2 ";
    }
    print OUT "\n";
    foreach $j (@edges) {
        print OUT "1 ";
    }
    print OUT "\n";

    foreach $j (@edges) {
        my @entry = @{ $vertices[ $j->[0] ] };
        my $point = pop @entry;
        @entry = ();
        push( @entry, $point->[0] );
        push( @entry, $point->[1] );
        push( @entry, $point->[2] );
        print_point \@entry;
        @entry = @{ $vertices[ $j->[1] ] };
        $point = pop @entry;
        @entry = ();
        push( @entry, $point->[0] );
        push( @entry, $point->[1] );
        push( @entry, $point->[2] );
        print_point \@entry;
        print OUT "\n";
    }
    foreach $j (@edges) {
        print_random_color;
    }
    end_entry;
    close(OUT);

    # het feest is compleet, het power diagram is daar.
    @halfspaces = ();
    open( IN, "< $infile" ) or die "The file $infile does not exist!\n";
    $count = 0;
    while (<IN>) {
        my @lineguy = split( ' ', $_ );
        my @entry   = ();
      SWITCH: {
            if ( $count < 3 ) {
                last SWITCH;
            }

            # being over here you have a point;
            my $sum =
              -0.5 * $lineguy[3] * $lineguy[3] + 0.5 * $lineguy[2] * $lineguy[2]
              + 0.5 * $lineguy[1] * $lineguy[1] + 0.5 * $lineguy[0] *
              $lineguy[0];
            push( @halfspaces,
                [ $lineguy[0], $lineguy[1], $lineguy[2], -1.0 * $sum ] );
        }
        $count++;
    }
    close(IN);

    # a polytope in r4 has 3 dimensional simplices
    # these have four vertices. So if $#halfspaces < 4 then
    # it's really easy to figure out what the
    # convex hull is. All points lie on it
    if ( $#halfspaces < 1 ) {
        die "You are a dangerous lunatic!\nAnd you know why..\n";
    }
    if ( $#halfspaces < 4 ) {
        open( OUT, ">> $outfile" );
        start_entry;
        print OUT "VECT\n";
        print OUT $#halfspaces * ( $#halfspaces + 1 ) * ( 1 / 2 );
        print OUT " ";
        print OUT $#halfspaces * ( $#halfspaces + 1 );
        print OUT " 1\n";
        foreach $count (
            1 .. ( $#halfspaces * ( $#halfspaces + 1 ) * ( 1 / 2 ) ) )
        {
            print OUT "2 ";
        }
        print OUT "\n1 ";
        foreach $count (
            1 .. ( $#halfspaces * ( $#halfspaces + 1 ) * ( 1 / 2 ) - 1 ) )
        {
            print OUT "0 ";
        }
        print OUT "\n";

        # number of lines
        foreach $count ( 0 .. $#halfspaces ) {
            foreach $j ( $count + 1 .. $#halfspaces ) {
                my @entry = @{ $halfspaces[$j] };
                pop @entry;
                print_point \@entry;
                @entry = @{ $halfspaces[$count] };
                pop @entry;
                print_point \@entry;
                print OUT "\n";
            }
        }
        print_random_color;
        end_entry;
        close(OUT);
        die "Thats all folks!\n";
    }

    # nu zit er in die halfspaces een hoeveelheid
    # punten, daarvan willen we het convex omhulsel
    # bepalen en dan de lower faces pakken

    $outfile = $infile . '.QCONVEXinput';
    open( OUT, "> $outfile" );
    print OUT "4 \n";
    print OUT $#halfspaces + 1;
    print OUT "\n";
    foreach $j (@halfspaces) {
        print_point $j;
        print OUT "\n";
    }
    close(OUT);
    $cmdline = 'qconvex n i < ' . $outfile . ' > ' . $infile . '.QCONVEXoutput';
    system($cmdline);

    # qconvex
    open( IN, '< ' . $infile . '.QCONVEXoutput' );
    @simplices   = ();
    $nosimplices = -20;

    $count = 0;
    while (<IN>) {
        s/ *$//;
        s/^ *//;
        my @lineguy = split( ' ', $_ );
        my @entry   = ();
      SWITCH: {
# on the second line you see the number of 
# simplices
            if ( $count == 1 ) {
                $nosimplices = $_;
                last SWITCH;
            }
# from the third line on you see the simplices
# thus the last simplex is on line no. $nosimplices + 2
            if ( $count > 1 && $count < $nosimplices + 2 ) {
                if ( $lineguy[3] > 0 ) {

                    # that's when he's fine
                    push( @simplices, 1 );
                }
                else {

                    # that's when he is not fine
                    push( @simplices, 0 );
                }
                last SWITCH;
            }
# after that you find one line which contains again
# the number of simplices
            if (   $count > $nosimplices + 2
                && $#simplices > -1 )
            {
                if ( $simplices[ $count - $nosimplices - 3 ] == 1 ) {
                    $simplices[ $count - $nosimplices - 3 ] = \@lineguy;
                }
                last SWITCH;
            }
        }
        $count++;
    }
    close(IN);
# ok, now you have the lower convex hull in the bag
# it is best to just throw in an off item
# those are planes, and so you can click them away
# using the appearance dialog
# but for the off item you need to find all the 
# two dimensional faces of the cells in the
# Delaunay triangulation

    @colors=();
    foreach $j (@halfspaces) {
      push(@colors,&get_random_color);
    }

    $outfile=$infile.'.list';
    open(OUT, ">> $outfile");
    foreach $j (@simplices) {
      if ( $j !=0 ) {
	&start_entry;
	print OUT "CQUAD\n";
	  my @entry=@{$halfspaces[$j->[0]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[0]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[1]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[1]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[2]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[2]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[3]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[3]];
	  print OUT "\n";
	&end_entry;
	&start_entry;
	print OUT "CQUAD\n";
	  @entry=@{$halfspaces[$j->[0]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[0]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[1]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[1]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[3]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[3]];
	  print OUT "\n";
	  @entry=@{$halfspaces[$j->[2]]};
	  pop @entry;
	  print_point \@entry;
	  print_point $colors[$j->[2]];
	  print OUT "\n";
	&end_entry;
      }
    }
    close(OUT);
        die "Thats all folks!\n";
}
