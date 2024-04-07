import unittest
import numpy as np
import context
from circuit import compute_center

class TestComputeCenter(unittest.TestCase):

  def test_valid_input(self):
    """Tests the function with valid input."""
    pts = np.array([[1, 2.1], [3, 4], [5, 6]])
    weights = np.array([1, 2, 3])
    center = compute_center(pts, weights)
    # Assert that the center has the expected shape and data type
    self.assertEqual(center.shape, (2,))
    self.assertTrue(np.issubdtype(center.dtype, np.float))

  def test_negative_weights(self):
    """Tests the function with negative weights."""
    pts = np.array([[1, 2.1], [3, 4], [5, 6]])
    weights = np.array([-1, 2, 3])
    # Assert that the function adjusts negative weights
    center = compute_center(pts, weights)
    self.assertTrue(np.all(weights >= 0))

  def test_unequal_length(self):
    """Tests the function with unequal pts and weights length."""
    pts = np.array([[1, 2.1], [3, 4], [5, 6]])
    weights = np.array([1, 2])
    # Assert that the function raises an error for unequal length
    with self.assertRaises(RuntimeError):
      compute_center(pts, weights)

  def test_invalid_point_dimension(self):
    """Tests the function with invalid point dimension."""
    pts = np.array([[[1, 2.1]], [3.3, 4], [5, 6]])
    weights = np.array([1, 2, 3])
    # Assert that the function raises an error for invalid point dimension
    with self.assertRaises(RuntimeError):
      compute_center(pts, weights)

  # Add more tests for specific expected center positions with known inputs
  def test_known_center_1d(self):
    """Tests the function with a known center in 1D."""
    pts = np.array([1, 3, 5])
    weights = np.array([2, 1, 3])
    expected_center = 3
    center = compute_center(pts, weights)
    self.assertAlmostEqual(center, expected_center)

  def test_compute_center_orig1(self):
    """full dimension test"""
    n=4
    pts=np.identity(n)
    pts2=np.stack(pts,pts[0])
    n1=len(pts2)
    weights=np.repeat(1.1,n1)
    expected_center=np.zeros(n1)
    center=compute_center(pts2,weights)
    self.assertAlmostEqual(center, expected_center)

  def test_compute_center_orig2(self):
    """full dimension test"""
    n=4
    pts=np.identity(n)
    pts2=np.stack(pts,pts[0])
    n1=len(pts2)
    weights=np.repeat(0.0,n1)
    pts2[0,0]=1.25
    weights[0]=0.5
    expected_center=np.zeros(n+1)
    center=compute_center(pts2,weights)
    self.assertAlmostEqual(center, expected_center)

  def test_compute_center_orig3(self):
    """full dimension test"""
    n=4
    pts=np.identity(n)
    pts2=np.stack(pts,pts[0])
    n1=len(pts2)
    weights=np.repeat(0.0,n1)
    pts2[0,0]=1.25
    weights[0]=0.5
    expected_center=np.zeros(n+1)
    center=compute_center(pts2[::2],weights[::2])
    self.assertAlmostEqual(center, expected_center)

  def test_compute_center_orig4(self):
    """d points in Rn
    take points with random weights
    then compute the affine functions?
    here we compute the distances
    """
    n=6
    d=3
    pts=np.random.rand(n,d)
    weights=np.random(d)
    center=compute_center(pts,weights)
    # check that the 
    pts2=pts-center
    dists=np.sqrt(np.diagonal(np.dot(pts2,np.transpose(pts2))))
    radii=np.sqrt(weights)
    totaldists=dists+radii
    average_difference=totalmean-np.mean(totaldists)
    self.assertAlmostEqual(average_differences, np.zeros(d))

  def test_compute_center_orig4(self):
    """d points in Rn
    
    """
    n=6
    d=3
    pts=np.random.rand(n,d)
    weights=np.random(d)
    nrms=np.linalg.norm(pts,axis=1)**2/2
    # transform the weights into the cvec
    cvec=weights-nrms
    center=compute_center(pts,weights)
    # check that the 
    np.inner(pts,center)+cvec
    pts2=pts-center
    dists=np.sqrt(np.diagonal(np.dot(pts2,np.transpose(pts2))))
    radii=np.sqrt(weights)
    totaldists=dists+radii
    average_difference=totalmean-np.mean(totaldists)
    # we check that the differences are the same but we
    # should also check the rank of the pts-center
    # that matrix should not have full rank
    self.assertAlmostEqual(average_differences, np.zeros(d))

  def test_compute_center_orig5(self):
    """d points in Rn with random weights """
    n=6
    d=3
    pts=np.random.rand(6,3)
    weights=np.random(3)
    center=compute_center(pts,weights)
    # check that the 
    pts2=pts-center
    dists=np.sqrt(np.diagonal(np.dot(pts2,np.transpose(pts2))))
    radii=np.sqrt(weights)
    totaldists=dists+radii
    average_difference=totalmean-np.mean(totaldists)
    self.assertAlmostEqual(average_differences, np.zeros(d))

if __name__ == '__main__':
  unittest.main()

