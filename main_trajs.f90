program van_der_waals

use temperature
use initial
use PeriodicBoundaryConditions
use integrator
use forces_routines
use statistics
use vmd

implicit none
! N: number of time steps
! M: number of atoms
! boxL: boxlength
! mass: particle mass
! rho: density
! kBTref: reference temperature
! nf: degrees of freedom
! ecin: kinetic energy
! epot: potential energy
! temp: temperature
! F: Force Matrix
! sigma: sigma parameter of lennard jones potencial
! epsil: epsilon parameter of lennard jones potencial
! nhis: number of edges on g(r) histogram
! tterm: temps que tarda en termalitzar. A partir d'aquí guardem trajs
! stepwrite: cada quants steps de temps escrivim

! system parameters
integer :: M, nf, nhis, stepwrite
double precision :: boxL, mass, kBTref, tterm
double precision :: sigma, epsil, utime
! Integration parameters
integer :: i, j, N
double precision :: dt
! General variables
double precision, dimension(:,:), allocatable :: r, v, F,F_t
! Ouputs
double precision :: ecin, epot, temp
! defining parameters
parameter(M = 500, N = 4000, nhis = 400)
parameter(mass = 1., sigma=1, epsil=1)
parameter(tterm = 4, stepwrite=10)

! Defining dimensions
allocate(r(3,M), v(3,M), F(3,M),F_t(3,M))

! Init variables
kBTref = 2.
boxL=10d0 / sigma
utime = dsqrt(mass * sigma**2 / epsil) ! unit of time in LJ units
dt = 1. / 300 / utime
nf = 3 * M - 3 ! number of degrees of freedom 

! Open files
open(unit=10, file='data/params.data', status='unknown')
open(unit=11, file='data/posicions.data', status='unknown')
open(unit=12, file='data/velocitats.data', status='unknown')
open(unit=20, file='data/traj_vmd.data', status='unknown')

! save parameters
write(10,*) boxL, nhis, M, sigma, epsil, mass, dt, stepwrite
close(10)

! Initial configuration+velocity

call inirandom(M,r,v,boxL,kBTref)


call PBC(M,r,boxL)
call forces(M,r,F,boxL,sigma,epsil,epot)

! Temporal loop
do i = 1, N

   call Verlet_Coord(r,F,v,M,dt,mass,boxL)

   ! Apply PBC

   call PBC(M,r,boxL)

   ! Calculate new Forces

   call forces(M,r,F_t,boxL,sigma,epsil,epot)

   call Verlet_Vel(F,F_t,v,M,dt,mass)
   
   !write trajectories
   If (i*dt > tterm .AND. mod(i,stepwrite) ==  0) then
       !write (*,*) i,dt,i*dt
       call output(M,i,dt,r)
       do j = 1, M
          write(11,*) r(1,j), r(2,j), r(3,j)
          write(12,*) v(1,j), v(2,j), v(3,j)
       end do
   endif

   F = F_t

end do

close(5)
close(6)
close(7)
close(20)

end program
