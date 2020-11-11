

use Tk;

# $tbase = 80000;   # Periode de la fondamentale (ms)
# $harmo1 = 60;     # Numero de la plus petite harmonique affectee a une boule
# $n = 15;               # Nombre de boules
$tbase = 80000;   # Periode de la fondamentale (ms)
$harmo1 = 4;     # Numero de la plus petite harmonique affectee a une boule
$n = 40;               # Nombre de boules

$r = 10;               # Rayon des boules
$dh = 20;              # separation verticale entre les boules
$ampli = 200;          # Amplitude des oscillations

$tau = 5;              # Periode de calcul (ms)

$largeur = 2 * $ampli + 100;        # Largeur "utile" du canvas
$margel = 170;                      # Marge gauche du canvas (pour textes)
$hauteur = ($n + 1) * $dh;          # Hauteur du canvas

$stop = 1;             # Indicateur marche/arret
$init = 0;             # Indicateur initialisation faite
$t = 0;                # Duree ecoulee depuis le lache des boules
$heure = "-------";    # Heure affichee avant initialisation

# Calcul des periodes
for ($i=0; $i<$n; $i++) {
    $periode[$i] = $tbase / ($harmo1 + 1 + $i); 
}

# Creation des widgets
my $mw = MainWindow->new;
$mw->title("Les pendules");
$cnv = $mw->Canvas(-width => $margel + $largeur,
                   -height => $hauteur)->pack();
$mw->Button(-text => "Init", -command => sub { initialiser(); })->pack(-side => 'left');
$mw->Button(-text => "Marche", -command => sub { $stop = 0 if $init; })->pack(-side => 'left');
$mw->Button(-text => "Arret", -command => sub { $stop = 1; })->pack(-side => 'left');
$mw->Button(-text => "Graticule", -command => \&graticule)->pack(-side => 'left');
$mw->Button(-text => "Couleur", -command => sub { $colorisation = 1 - $colorisation;})->pack(-side => 'left');
$mw->Label(-textvariable => \$heure)->pack(-side => 'right');

# Couleur du fond du canvas
my $couleurFond = $cnv->cget(-background);

# Trace du graticule
$graticule = 0;  # Le graticule sera initialement invisible
my $x0 = $margel + $largeur/2;
$cnv->createLine($x0, 0, $x0, $hauteur, -tags => "graticule",
                                        -width => 2, -fill => $couleurFond);
for ($i = 1; $i < 5; $i++) {
     my $deltax = $i * $largeur / 10;
     $cnv->createLine($x0 + $deltax, 0, $x0 + $deltax, $hauteur, -tags => "graticule", -fill => $couleurFond);
     $cnv->createLine($x0 - $deltax, 0, $x0 - $deltax, $hauteur, -tags => "graticule", -fill => $couleurFond);
}
for ($i = 0; $i<$n; $i++) {
    my $y = $hauteur - $dh - $i * $dh;
    $cnv->createLine($margel + 30, $y, $margel + $largeur - 30, $y, -tags => "graticule", -fill => $couleurFond);
}

# Creation des boules et affichage des labels
for ($i = 0; $i<$n; $i++) {
    $x[$i] = $margel + $largeur / 2;
    $y[$i] = $hauteur - $dh - $i * $dh;
    $id[$i] = $cnv->createOval($x[$i] - $r, $y[$i] - $r, $x[$i] + $r, $y[$i] + $r, -fill => "blue");
    my $g = 9.81;                                       # Acceleration pesanteur
    my $harmonique = $harmo1 + $i;                      # Numero de l'harmonique
    my $T = $periode[$i] / 1000;                        # Periode en seconde
    my $longueur = $T * $T * $g / (4 * 3.14 * 3.14);    # Longueur en m 
    my $label = sprintf("H = %2d   T = %6.03f s   L = %5.02f m",
                        $harmonique, $T, $longueur);
    $cnv->createText(10, $y[$i], -text => $label, -anchor => "w");
}

# Horloge de sequencement du calcul
$cnv->repeat($tau, \&vivre);

# Boucle principale de la simulation
MainLoop; 


sub vivre
{
    return if $stop;

    $t += $tau;
    positionner_boules();
}

sub positionner_boules
{
    for ($i = 0; $i<$n; $i++) {
        # print "x[$i] = $x[$i]\n";
        $x[$i] = $margel + $largeur / 2 + $ampli * cos(6.28 * $t / $periode[$i]);
        # if ($x[$i] > ($margel + $largeur)) { $x[$i] -= $largeur; }
        $cnv->coords($id[$i], $x[$i] - $r, $y[$i] - $r, $x[$i] + $r, $y[$i] + $r);

        if ($colorisation) {
            my $derivee = - sin(6.28 * $t / $periode[$i]);
            if (($derivee < 0) && $colorisation) {
                $cnv->itemconfigure($id[$i], -fill => "red");
            } else {
                $cnv->itemconfigure($id[$i], -fill => "blue");
            }
        }

    }

    $heure = sprintf("t = %08.03f s", $t / 1000);
}

sub initialiser
{
    $init = 1;
    $stop = 1;
    $t = 0;
    positionner_boules;
    $heure="t = 0000.000 s";
}

sub graticule
{
    # Affichage ou dissimulation du graticule
    my $couleur;
    if ($graticule) {
        $graticule = 0;
        $couleur = $couleurFond;
    } else {
        $graticule = 1;
        $couleur = "black";
    }
    $cnv->itemconfigure("graticule", -fill => $couleur);
}


