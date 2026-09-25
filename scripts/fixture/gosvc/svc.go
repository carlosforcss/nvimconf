package svc
type Store struct{}
type Reader interface{ Read() }
type Pair[T any] struct{ a T }
func NewStore() *Store { return &Store{} }
func (s *Store) Get(id string) string { return id }
func (p Pair[T]) First() T { return p.a }
